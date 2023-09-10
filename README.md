# A project template for Python

<a href="https://github.com/azataiot/python-project-template/generate"><img src="https://img.shields.io/badge/use%20this-template-blue?logo=github" alt="use-this-repo-badge"></a>
[![Code Quality](https://github.com/azataiot/python-project-template/actions/workflows/code-quality.yml/badge.svg)](https://github.com/azataiot/python-project-template/actions/workflows/code-quality.yml)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)
[![security: bandit](https://img.shields.io/badge/security-bandit-yellow.svg)](https://github.com/PyCQA/bandit)
[![latest release](https://img.shields.io/github/v/release/azataiot/python-project-template)](https://github.com/azataiot/python-project-template/releases)

**Introduction**: This repository provides a comprehensive project template for GitHub repositories. It's designed to
streamline the setup process, ensuring best practices and essential components are included. By using this template, you
can ensure a consistent and professional structure for your projects, making them more accessible and maintainable.

## Usage

### Create a new repository from this template

1. [Click here](https://github.com/azataiot/project-template/generated) to create a new repository with this template.
2. Select and Add a license.

### Initialize and install `pre-commit` hooks

1. Install [pre-commit](https://pre-commit.com/#install). (skip this step if you already have pre-commit installed)
2. Run `pre-commit install` to install the pre-commit hooks.
3. Run `make pre-commit` to run the pre-commit hooks on all files.

### Setup GitHub Branch Protection

1. Go to `Settings` > `Branches` > `Branch protection rules` > `Add rule`
2. Add the following rules:
    - `main`
        - Require a pull request before merging
        - Require status checks to pass before merging
        - Require branches to be up-to-date before merging
        - Add `linting` status checks ( and others if you created them )
        - Do not allow bypassing the above settings
    - `dev`
        - Require a pull request before merging
        - Require status checks to pass before merging
        - Add `linting` status checks ( and others if you created them )

**Why Branch Protection?**: Branch protection ensures that changes to important branches undergo a review process. This
maintains code quality and prevents potential issues from being merged.

## Branching Strategy

- `main`: The main branch. This branch is protected and cannot be pushed directly. (PRs must be made to `dev` instead
  of `main`)
- `dev`: The development branch. This branch is protected and cannot be pushed directly. (PRs must be made to this
  branch)
- `feature/*`: The 'feature/*' branches are used to develop new features for the upcoming or a distant future release.
  These branches are branched off from 'dev' and must merge back into `dev`.
- `release/*`: The 'release/*' branches are used to prepare the next release. They allow for last-minute changes and
  minor bug fixes. These branches are branched off from 'dev' and must merge back into `main` and `dev`.
- `hotfix/*`: The 'hotfix/*' branches are used to develop fixes for the current release. These branches are branched off
  from `main` and must merge back into `main`.

## How to create a python package with this template? (WIP)

1. Create a new repository from this template. (
   see [Create a new repository from this template](#create-a-new-repository-from-this-template))
2. Place your package code in the `src` directory.
3. Update the `pyproject.toml` file with your package details.
4. Set up your PyPI account and create a new API token. (see [PyPI Help #api-token](https://pypi.org/help/#apitoken))
   1. Go to [PyPI](https://pypi.org/) and create an account, if you don't have one already.
   2. Generate a PyPI API token. (see [PyPI Help #api-token](https://pypi.org/help/#apitoken)), this gives you something similar to this:
    ![](https://raw.githubusercontent.com/azataiot/images/master/2023/09/upgit_20230910_1694355387.png)
   3. run `poetry config pypi-token.pypi <your-api-token>` to set the API token.
5. run `poetry build` to build the package.
6. run `poetry publish` to publish the package to PyPI.

## Contributing

Contributions are always welcome! Whether it's bug reports, feature requests, or pull requests, all contributions are
appreciated. For more details, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under some License. For more details, see [LICENSE](LICENSE.md).

## Code of Conduct

We believe in fostering an inclusive and respectful community. For guidelines and reporting information,
see [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Security

Your security is paramount. If you discover any security-related issues, please follow the guidelines
in [SECURITY.md](SECURITY.md).

## Founding

For information about the project's founding and backers, see [FOUNDING](https://github.com/sponsors/azataiot).
