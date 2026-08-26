# FRONT_BLOCKERS

Relevé fait en intégrant la maquette Figma
[« Activities By buddies du wagon - Ecrans »](https://www.figma.com/design/3CaB8DHopam9un4TN3gsSZ/le-wagon-activities-simple-copie?node-id=1-206)
dans les vues.

Aucun de ces points n'a été corrigé : le travail front s'est limité à `app/views/**`,
`app/assets/**` et `app/helpers/**`. Models, controllers, routes, migrations et Gemfile
sont restés intacts.

Les vues sont écrites comme si ces points étaient résolus, sauf mention contraire.

**État au 26/08, `origin/master` = `0ddf0fc`.** Corrigés depuis le premier relevé :
`Profile has_many :user_activities` (§1.7, Florian, `0c6f0b3`) et l'auteur sur
`events#create` / `messages#create` (§1.2 et §2.4, Clément, `a4fce67`) — les deux
partiellement, voir le détail dans chaque section. Tout le reste est inchangé.

---

## 1. Bloquants — la maquette ne peut pas s'afficher correctement

### 1.1 `Event` valide une colonne qui n'existe pas

`app/models/event.rb` valide `max_nb_participant`, or la colonne du schema est `max_participant`.
`events_controller.rb` permet lui aussi `:max_nb_participant`.

Tout submit du formulaire event lève `NoMethodError`. Le champ « participants max » de la
maquette est donc câblé sur `max_participant` (le vrai nom) et restera cassé tant que le
modèle validera l'autre.

### 1.2 `events#create` ne renseigne pas `activity`

> **Partiellement corrigé** par `a4fce67` (Clément, PR #13) : `@event.user = current_user`
> est maintenant présent. Le reste tient toujours.

`Event belongs_to :activity`, mais `create` ne set pas l'activité et `event_params` ne permet
pas `:activity_id`. `activity_id` étant `null: false` au schema, la création échoue toujours
systématiquement — le `save!` lève `ActiveRecord::NotNullViolation`.

Le formulaire `events/new` doit exposer un select d'activités, et `event_params` permettre
`:activity_id`.

Impact maquette : l'écran `activity page` affiche l'organisateur et le nom de l'activité
(« Tennis »). Les deux viennent de ces associations.

### 1.3 Pas d'Active Storage

Aucune table `active_storage_*`, pas de gem. La maquette repose sur des visuels à trois endroits :

- vignette de carte activité (108×108, radius 8)
- avatar utilisateur du header (44px) et des profils
- pile d'avatars « +4 going » sur chaque carte

En attendant, ces zones utilisent la pastille `#e3f2ea` de la maquette (c'est littéralement
ce que contiennent les SVG exportés). Le markup est prêt à recevoir un `image_tag` sans
changer la structure.

### 1.4 `start_date` / `end_date` sont des `t.time`

La maquette affiche « Sat 10:00 » sur les cartes et « Saturday, 10:00 — 11:30 » sur le détail.
Une colonne `time` ne porte aucune date : impossible d'en tirer un jour de la semaine, de
trier par date ou de filtrer les événements passés.

Les vues n'affichent donc que l'heure. Migration en `datetime` nécessaire pour la maquette réelle.

### 1.5 Aucune donnée de géolocalisation

La maquette affiche « 2.3 km » sur les cartes et chips, « 1.4 km away » sur les lignes buddy.
Il n'y a ni latitude/longitude ni geocoder — seulement `events.location` et `profiles.location`
en `string`.

Ces mentions de distance sont absentes des vues. Elles demandent une migration + un geocoder.

### 1.6 L'écran « Users » n'a pas de route

La maquette a un toggle segmenté Buddies | Activities reliant deux écrans :
« Open Activities » (→ `events#index`) et « Compatible buddies » (→ un index d'utilisateurs).

`UsersController` est vide et `config/routes.rb` ne déclare pas `resources :users`.
Le côté Activities du toggle est câblé ; le côté Buddies est rendu inerte (`aria-disabled`).

Il faut une route index + l'action correspondante.

### 1.7 `UserActivity` pointe vers une colonne qui n'existe pas

La table `user_activities` est clé sur **`profile_id`** :

```ruby
create_table "user_activities" do |t|
  t.bigint "activity_id", null: false
  t.string "level"
  t.bigint "profile_id", null: false   # <- pas user_id
end
add_foreign_key "user_activities", "profiles"
```

Or le modèle déclare `belongs_to :user`. Il n'y a aucune colonne `user_id` : toute écriture
lève `ActiveModel::MissingAttributeError`, toute lecture via l'association échoue.

Casse en cascade :

- `UserActivity belongs_to :user`
- `User has_many :user_activities` et `has_many :activities, through: :user_activities`
- `Activity has_many :users, through: :user_activities`

Impact maquette, direct et large :

- les colonnes **Sports / Hobbies** de la `User page`
- le badge de niveau **« Intermediate »** sur chaque ligne buddy et sur `activity page`

**Moitié corrigé depuis.** Le commit `0c6f0b3` a ajouté sur `Profile` :

```ruby
has_many :user_activities, dependent: :destroy
has_many :activities, through: :user_activities
```

La **lecture** fonctionne donc maintenant : `profile.user_activities` résout, et
`ApplicationHelper#profile_activities` a été simplifié pour l'utiliser.

**L'écriture reste cassée** : `UserActivity` déclare toujours `belongs_to :user` alors
qu'aucune colonne `user_id` n'existe. Conséquence directe — les champs imbriqués
`simple_fields_for @user_activity` du formulaire `profiles/new` échoueront à la
sauvegarde dès que le `raise` du §2.0 sera retiré.

Il reste à passer `UserActivity` sur `belongs_to :profile`, ou à renommer la colonne.

---

## 2. Bugs — cassent le fonctionnement, indépendamment du front

### 2.0 🔴 URGENT — un `raise` est mergé sur `master`

`app/controllers/profiles_controller.rb`, commit `0c6f0b3` :

```ruby
def create
  raise                                   # <- laissé en place
  @profile = Profile.new(profile_params)
```

Toute création de profil lève immédiatement. Le formulaire `profiles/new` du même
commit ne peut donc rien enregistrer. À retirer en priorité.

### 2.1 `save!` dans un `if` : les erreurs de formulaire ne s'affichent jamais

Présent dans `events#create`, `events#update`, `profiles#create`, `profiles#update`,
`event_memberships#create`, `event_memberships#update`, `messages#create`.

`save!` lève `ActiveRecord::RecordInvalid` au lieu de renvoyer `false`. La branche `else`
est morte : au lieu de re-rendre le formulaire avec les erreurs, l'app renvoie une 500.

Le markup d'erreur est en place dans les vues (simple_form s'en charge) mais ne sera jamais
atteint tant que le `!` est là. `save` sans bang suffit.

### 2.2 `profiles#create` / `#update` redirigent vers `profile_path(@chat)`

`@chat` n'existe pas dans `ProfilesController`. Vaut `nil` → `NoMethodError`.
C'est très probablement `profile_path(@profile)`.

### 2.3 `profiles#update` appelle `update` sur la classe

```ruby
@profile = Profile.update(profile_params)   # classe, pas instance
```
Devrait être `@profile = Profile.find(params[:id])` puis `@profile.update(profile_params)`.
Même schéma dans `event_memberships#update` (`EventMembership.update(...)`).

### 2.4 🔴 `messages#create` sauvegarde le mauvais objet

> **Partiellement corrigé** par `a4fce67` (Clément, PR #13) : `@message.user = current_user`
> est maintenant présent. Le bug principal tient toujours — et il est désormais silencieux.

```ruby
@message = Message.new(message_params)
@message.chat = @chat
@message.user = current_user
if @chat.save!        # sauve le chat, jamais le message
```

Assigner `@message.chat` renseigne le `belongs_to` côté message ; ça n'ajoute rien à
`@chat.messages`. `@chat.save!` sauve donc un chat inchangé, renvoie `true`, et le message
part à la poubelle. Il faut `@message.save`.

Reproduit sur la base de dev, transaction annulée :

```
chat.save! returned       : true
message.persisted?        : false
Message.count before/after : 20 / 20
```

C'est le pire profil de bug : l'action redirige vers le chat comme si tout allait bien.
Aucune exception, aucun log, le message disparaît. Le `current_user` ajouté est posé sur un
objet qui n'est jamais écrit.

### 2.5 Association `events_as_participant` invalide

```ruby
has_many :events_as_participant, through: :event_membership, source: :event
```
`User` déclare `has_many :event_memberships` (pluriel). `:event_membership` n'existe pas sur
`User` → lève dès l'appel. C'est l'association qui alimenterait « mes événements ».

### 2.6 `validates :is_admin, presence: true` rejette `false`

`presence` sur un booléen refuse `false`. Un membre non-admin ne peut donc pas être créé.
Utiliser `inclusion: { in: [true, false] }`.

### 2.7 `User` n'a pas de `has_one :profile`

`Profile belongs_to :user`, mais `User` ne déclare aucune association inverse.
`current_user.profile` lève donc `NoMethodError`.

Le header et le menu du compte ont besoin du profil de l'utilisateur courant. En attendant,
`ApplicationHelper#current_profile` fait un `Profile.find_by(user: current_user)`. Ce helper
est à supprimer dès que l'association existe.

---

### 2.8 `event_memberships#create` ne renseigne pas `user`

```ruby
@event_membership = EventMembership.new(event_membership_params)
@event_membership.event = @event
if @event_membership.save!    # user jamais assigné
```

`EventMembership belongs_to :user` : la validation échoue toujours, et comme c'est un `save!`
(cf. §2.1) la requête renvoie une 500 au lieu de re-rendre.

C'est le CTA « Send a request » de `activity page`, l'action centrale de la maquette.
Il faut `@event_membership.user = current_user`.

---

## 3. Remarques de schéma

### 3.1 Double clé étrangère entre `users` et `profiles`

`users.profile_id` et `profiles.user_id` coexistent. Un seul sens suffit ; en garder deux
laisse les deux se désynchroniser. `Profile belongs_to :user` suggère de supprimer
`users.profile_id`.

### 3.2 `Event has_many :event_membership` au singulier

Fonctionne, mais casse la convention et rend `event.event_membership.count` trompeur à la
lecture. Les vues utilisent cette association telle quelle pour le compteur « +N going ».

### 3.3 `profiles` n'a pas de champ avatar

Même sans Active Storage, la maquette met un avatar sur chaque ligne buddy, chaque message
et chaque profil.

---

## 4. Ce que la maquette suppose et qui n'existe pas encore

### 4.1 `pages#home` ne charge aucune donnée

`PagesController#home` est vide : aucune variable d'instance. Or la Homepage de la maquette
affiche « ACTIVITIES NEAR YOU » suivi de cartes activité.

`ApplicationHelper#home_feed_events` fait la requête depuis la vue pour que l'écran s'affiche.
C'est un dépannage, pas une cible : déplacer en `@events` dans le controller.

### 4.3 Le Stimulus `add_form_input` ne réindexe pas les champs

`add_form_input_controller.js` duplique le bloc par `innerHTML` :

```js
this.formTarget.insertAdjacentHTML("afterend", this.formTarget.innerHTML)
```

Les champs copiés gardent des attributs `name` identiques. Rails ne retiendra donc que
la **dernière** ligne d'activité saisie, quel que soit le nombre de lignes ajoutées.

Il faut réindexer les `name` (`profile[user_activities_attributes][N][...]`) et déclarer
`accepts_nested_attributes_for :user_activities` sur `Profile`.

### 4.4 `f.submit` ne porte aucune classe

Dans `profiles/new`, `<%= f.submit %>` rend `<input type="submit">` sans classe :
`config.button_class = 'btn'` ne s'applique qu'à `f.button`, pas à `f.submit`.

Contourné côté CSS par `.form_container input[type="submit"]`. Utiliser
`f.button :submit` rendrait l'override inutile.

| Élément maquette | Ce qu'il faudrait |
|---|---|
### 4.2 Le CTA « Send a request » d'un profil n'a pas de destination

`User page` a un bouton « Send a request » vers un autre utilisateur. Rien ne le porte :

- `EventMembership` est lié à un **événement**, pas à une personne
- `chats#create` est imbriqué sous `events` (`/events/:event_id/chats`)
- il n'existe aucune notion de demande d'ami ni de conversation directe

Le bouton est rendu `disabled` en attendant une route.

| Recherche « Search an activity » | une action de recherche + param ; le champ est présent mais inerte |
| « Add to calendar » (Chat page) | une route d'export ICS |
| Bouton « Message » (activity page) | `chats#create` existe en route imbriquée, non câblé à l'organisateur |
| Badge « Confirmed » | `EventMembership::STATUS` utilise « Accepted » — libellé aligné sur le modèle |
| Colonnes Sports / Hobbies (User page) | dérivées de `Activity::GENRES` (`Sport`, `Culture`, `Relaxing`) |
