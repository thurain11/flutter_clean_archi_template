# Flutter Clean Architecture CLI (Mason)

Generate clean architecture feature folders/files for Flutter projects.

## Setup

```bash
dart pub get
```

Install globally (run once):

```bash
dart pub global activate --source path /Users/thurainhein/Documents/my_apps/cli_tool
```

If `ca_gen` command is not found, add pub global bin to PATH:

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

## Usage

```bash
dart run bin/cli_tool.dart post
```

After global activate:

```bash
ca_gen post
```

Install from GitHub (for other machines):

```bash
dart pub global activate --source git https://github.com/<your-username>/<your-repo>.git
ca_gen post
```

Generate directly inside another Flutter project:

```bash
dart run bin/cli_tool.dart post --project /absolute/path/to/flutter_project
```

### Optional flags

```bash
dart run bin/cli_tool.dart post --project /path/to/flutter_project
dart run bin/cli_tool.dart post -o /path/to/flutter_project
dart run bin/cli_tool.dart post --on-conflict overwrite
```

## Generated structure

```text
lib/features/post/
  data/
    datasources/post_remote_data_source.dart
    models/post_model.dart
    repositories/post_repository_impl.dart
  domain/
    entities/post.dart
    repositories/post_repository.dart
    usecases/get_post.dart
  presentation/
    bloc/post_bloc.dart
    bloc/post_event.dart
    bloc/post_state.dart
    pages/post_page.dart
```

## Make This Repo Shareable

1. Create a new empty repository on GitHub (for example `flutter-ca-gen`).
2. In this project folder, run:

```bash
git init
git add .
git commit -m "feat: initial ca_gen scaffold generator"
git branch -M main
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

3. On any other machine, install and use:

```bash
dart pub global activate --source git https://github.com/<your-username>/<your-repo>.git
ca_gen post
```

## Update Flow

After you push new changes to GitHub, reinstall on target machines:

```bash
dart pub global activate --source git https://github.com/<your-username>/<your-repo>.git
```
# flutter_clean_archi_template
