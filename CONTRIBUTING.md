# Contributing to this project

First off, thanks for taking the time to contribute! ❤️

## 💡 Best practices
- Docstring your functions and classes, it is even more important as it is used to generate the documentation with Mkdocs
- If you use an IDE, define src the "source" folder so your IDE can help you auto import files
- Use the `make` commands to run your code, it is easier and faster than writing the full command (and check the Makefile for all available commands 😉)
    - Run [Use the pre-commit hooks](https://pre-commit.com/) to ensure your code is formatted correctly and is of good quality
    - [UV](https://docs.astral.sh/uv/ ) is powerful (multi-thread, package graph solving, rust backend, etc.) use it as much as you can.
    - If you have a lot of data, use Polars for faster and more efficient dataframe processing.
    - If you have CPU intensive tasks, use multiprocessing with python's pool map.

- Exceptions:  
    - Always log the exceptions and errors (use loguru) and then raise them
    ```py
        except Exception as e:
          logger.error(e)  # Log the original error  with a personalized message or with e (only the message will be logged)
          raise e # All the stack trace will be logged
    ```
    - Sometimes, you don't need to raise the exception (in a loop for example) to not interrupt the execution.
    - Use if else instead of catching and raising the exception when possible (log and raise also)
      ```py
          if not os.path.exists(file_path):
              logger.error(f"File not found: {file_path}. The current directory is: {os.getcwd()}")
              raise FileNotFoundError(f"The file {file_path} does not exist.")
      ```
## How to contribute
### 1.File structure (🌳 Tree)

```
.
├── Makefile # makefile contains useful commands for the project
├── notebooks # notebooks folder
├── pyproject.toml # pyproject.toml file for the package, ruff, dependencies and uv package manager
├── README.md # this file
├── src # source code folder
└── tests # tests folder

```


[//]: # (todo add tree of files with explanations)

###  ⚙️ 2. Steps for Installation (Contributors and maintainers)

- The first step is [to install to read and test the project as a user](README.md#-steps-for-installation-users)
- Then you can either [develop in a container](#developing-in-a-container) or [develop locally](#local-development)

#### 2.1. Local development
- Requires Debian (Ubuntu 22.04) & python 3.11
- git clone the repository
- Install the package in editable mode with one of the following commands :
  - ``make install-dev`` the recommended way. it uses uv and will automatically create a .venv folder inside the project and install the dependencies
  - or ``uv pip install -e .`` will install the package in your selected environment (venv, or conda or ...)
  - (note recommended)  or ``pip install -e .`` if you don't have uv (we strongly recommend starting using uv)

#### 2.2. or Develop in a container
- If you have a .venv folder locally, you need to delete it, otherwise it will create a conflict since the project is mounted in the container.
- You can run a docker image containing the project with ``make docker-prod`` (or ``make docker-dev`` if you want the project to be mounted in the container).
- A venv is created inside the container and the dependencies are installed.

###  3. Run the test to see if everything is working
- Create a ``.env`` file *(take a look at the ``.env.example`` file)*:
- Test the package with :
    - ``make test-installation`` Will print a hello message
    - ``make test`` will run all the tests (requires .env file)

### 4. Pushing your work
- Before you start working on an issue, please comment on (or create) the issue and wait for it to be assigned to you. If
  someone has already been assigned but didn't have the time to work on it lately, please communicate with them and ask if
  they're still working on it. This is to avoid multiple people working on the same issue.
  Once you have been assigned an issue, you can start working on it. When you are ready to submit your changes, open a
  pull request. For a detailed pull request tutorial, see this guide.

1. Create a branch from the dev branch and respect the naming convention: `feature/your-feature-name`
   or `bugfix/your-bug-name`.
2. Before commiting your code :

   - Run ``make test`` to run the tests
   - Run ``make pre-commit`` to check the code style & linting. If it fails because gitguardien api key is not in your secret, add it in .secret. ggshield provides it for free.
   - Run ``make serve-docs`` to update the documentation
   - Update the ``pyproject.toml`` file and run ``make build-pacakge`` to build the package
   - (optional) Commit Messages: This project uses [Gitmoji](https://gitmoji.dev/) for commit messages. It helps to
     understand the purpose of the commit through emojis. For example, a commit message with a bug fix can be prefixed with
     🐛. There are also [Emojis in GitHub](https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md)
   - Manually, merge dev branch into your branch to solve and avoid any conflicts. Merging strategy: merge : dev →
     your_branch
   - After merging, run ``make test`` and ``make pre-commit`` again to ensure that the tests are still passing.
   - (if your project is a python package) Update the package’s version, in pyproject.toml & build the wheel
3. Run CI/CD Locally: Depending on the platform you use:
   - GitHub Actions: run `make install-act` then `make act` for GitHub Actions
   - GitLab CI: run `make install-gitlab-ci-local` then `make gitlab-ci-local` for GitLab CI.
4. Create a pull request. If the GitHub actions pass, the PR will be accepted and merged to dev.

### (For repository maintainers) Merging strategies & GitHub actions guidelines**

- Once the dev branch is tested, the pipeline is green, and the PR has been accepted, you can merge with a 'merge'
  strategy.
- DEV → MAIN: Then, you should create a merge from dev to main with Squash strategy.
- MAIN → RELEASE: The status of the ticket will change then to 'done.'
