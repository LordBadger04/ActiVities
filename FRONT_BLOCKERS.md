# FRONT_BLOCKERS

Relevé fait en intégrant la maquette Figma
[« Activities By buddies du wagon - Ecrans »](https://www.figma.com/design/3CaB8DHopam9un4TN3gsSZ/le-wagon-activities-simple-copie?node-id=1-206)
dans les vues.

Aucun de ces points n'a été corrigé : le travail front s'est limité à `app/views/**`,
`app/assets/**` et `app/helpers/**`. Models, controllers, routes, migrations et Gemfile
sont restés intacts.

Les vues sont écrites comme si ces points étaient résolus, sauf mention contraire.

**État au 26/08, `origin/master` = `e52273b`.**

Corrigés : `Profile has_many :user_activities` (§1.7), `max_nb_participant` (§1.1),
`activity_id` dans les strong params (§1.2), `has_many :event_memberships` au pluriel (§3.2).
Une colonne `event_date` a été ajoutée, ce qui règle l'essentiel de §1.4.

⚠️ **§3.4 est nouveau et concerne toute l'équipe** : la colonne `event_date` a été ajoutée en
modifiant une migration déjà jouée. `rails db:migrate` ne fera rien, et l'app plantera en
local chez tous ceux qui avaient déjà migré.

Toujours ouverts, par ordre de gravité : §2.0 (un `raise` bloque `profiles#create`),
§2.4 (les messages sont perdus en silence), §2.5, §2.3, §2.2, §2.6, §2.8.

---

## 1. Bloquants — la maquette ne peut pas s'afficher correctement

### 1.1 `Event` valide une colonne qui n'existe pas — ✅ corrigé

> **Corrigé** par `834e578`. Le modèle et `event_params` utilisent désormais `max_participant`.
> Vérifié : `Event.new(...).valid?` renvoie `true` au lieu de lever `NoMethodError`.

Pour mémoire : `app/models/event.rb` validait `max_nb_participant`, alors que la colonne
s'appelle `max_participant`. Aucun `Event` ne pouvait être enregistré.

⚠️ Le même motif est réapparu aussitôt sous une autre forme : `validates :event_date,
presence: true` a été ajouté sans que la colonne existe dans les bases déjà migrées. Voir §3.4.

### 1.2 `events#create` ne renseigne pas `activity` — ✅ corrigé

> **Corrigé** en deux temps : `a4fce67` a ajouté `@event.user = current_user`, `834e578` a
> ajouté `:activity_id` à `event_params`. Le formulaire `events/new` expose le select
> d'activités depuis le début côté front.

Pour mémoire : `activity_id` est `null: false` au schema, donc chaque création levait
`ActiveRecord::NotNullViolation`.

### 1.3 Pas d'Active Storage

Aucune table `active_storage_*`, pas de gem. La maquette repose sur des visuels à trois endroits :

- vignette de carte activité (108×108, radius 8)
- avatar utilisateur du header (44px) et des profils
- pile d'avatars « +4 going » sur chaque carte

En attendant, ces zones utilisent la pastille `#e3f2ea` de la maquette (c'est littéralement
ce que contiennent les SVG exportés). Le markup est prêt à recevoir un `image_tag` sans
changer la structure.

### 1.4 `start_date` / `end_date` sont des `t.time` — 🟡 en grande partie réglé

> Une colonne `t.date :event_date` a été ajoutée par `834e578`. Les deux libellés de la
> maquette sont donc rendus tels quels : `event_meta_line` donne « Tennis · Batignolles ·
> Sat 10:00 » et `event_when` donne « Saturday, 10:00 — 11:30 ». Les helpers tolèrent une
> date nulle et retombent sur l'heure seule, pour les events créés avant la colonne.
>
> ⚠️ La colonne n'apparaît pas avec un simple `rails db:migrate` — voir §3.4.

Ce qui reste : la date et l'heure vivent dans trois colonnes séparées (`event_date`,
`start_date`, `end_date`). Deux `datetime` seraient plus simples à trier, à comparer et à
filtrer sur les événements passés. Rien de bloquant pour la maquette.

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

### 3.2 `Event has_many :event_membership` au singulier — ✅ corrigé

> **Corrigé** par `834e578` : l'association est au pluriel. Les vues et le helper
> `event_attendees` ont été mis à jour côté front.

⚠️ `app/models/user.rb` n'a **pas** suivi : il déclare toujours
`has_many :events_as_participant, through: :event_membership`, qui pointe maintenant vers une
association inexistante. Voir §2.5.

### 3.3 `profiles` n'a pas de champ avatar

Même sans Active Storage, la maquette met un avatar sur chaque ligne buddy, chaque message
et chaque profil.

### 3.4 🔴 Une migration déjà jouée a été modifiée — à lire par toute l'équipe

`834e578` ajoute `t.date :event_date` à l'intérieur de
`db/migrate/20260824135902_create_events.rb`, une migration déjà poussée et déjà jouée.

Rails identifie une migration par sa version, pas par son contenu. `20260824135902` est déjà
inscrite dans `schema_migrations`, donc :

- `rails db:migrate` répond « nothing to migrate » et **n'ajoute jamais la colonne** ;
- `app/models/event.rb` valide pourtant `event_date` ;
- résultat : `NoMethodError` sur chaque `Event.new(...).valid?`, exactement le bug de §1.1
  que le même commit venait de corriger.

Seuls les collaborateurs qui n'avaient encore jamais migré sont épargnés. **Tous les autres
ont une app qui plante en local sans raison visible.**

Deux façons de s'en sortir, au choix :

```bash
bin/rails db:migrate:reset && bin/rails db:seed   # remet tout à plat, perd les données locales
```

```bash
# ou, sans rien perdre :
bin/rails runner 'ActiveRecord::Migration.new.add_column(:events, :event_date, :date)'
```

La règle pour la suite : **une migration poussée ne se modifie plus.** On en ajoute une
nouvelle (`rails g migration AddEventDateToEvents event_date:date`), qui porte une version
inédite et se joue donc chez tout le monde.

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
