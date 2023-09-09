## Developing a new feature

### Create a new branch from `dev` with the name `feature/<feature-name>`.

```bash
git checkout -b feature/<feature-name> dev
```

### Develop the feature.

```bash
git add <files>
git commit -m "feat: <commit-message>"
```

### Update the documentation.

Update the documentation in `docs/` folder if necessary.

### Update your local `dev` branch.

#### Update Your Local dev Branch:

```bash
git checkout dev
git pull origin dev
```

#### Mere or Rebase

Depending on your workflow, you can either merge the changes from main into your release/0.0.1 branch or rebase your
release/0.0.1 branch onto main.

**Merge:**

This will create a merge commit.

```bash
git checkout feature/<feature-name>
git merge dev
```

Resolve any conflicts if they arise, then commit the changes.

**Rebase:**

This will reapply the commits from your release/0.0.1 branch on top of the main branch, giving the appearance of a
linear history.

```bash
git checkout feature/<feature-name>
git rebase dev
```

Again, if conflicts arise, you'll need to resolve them for each commit during the rebase process. After resolving
conflicts for a particular commit, you can continue the rebase with `git rebase --continue`.

#### Push Your Changes to GitHub

After merging or rebasing, you can push the changes to the remote repository.

```bash
git push origin feature/<feature-name>
```

If you chose to rebase, you'll need to force push since the commit history has changed:

```bash
git push origin feature/<feature-name> --force-with-lease 
```

**OR:**

```bash
make push
```

### Create a pull request to merge the feature branch into `dev`.

```bash
make prdev
```

### After the pull request is merged, delete the feature branch.

```bash
make remove-branch
```

## Creating a new release

### Create a new branch from `dev` with the name `release/<version>`.

```bash
git checkout -b release/<version> dev
```

### Bump the version with `make version`

```bash
make version
```

### Update the documentation.

Update the documentation in `docs/` folder if necessary.

### Update your local `dev` branch.

Refer to the Developing a new feature section.

### Create a pull request to merge the release branch into`dev`.

Refer to the Developing a new feature section.

### Update your local `main` branch.

Refer to the Developing a new feature section.

### Create a pull request to merge the release branch into `main`.

Refer to the previous sections

### After the pull request is merged, delete the release branch.

Refer to the previous sections
