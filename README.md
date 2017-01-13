#[Stanford TravisCI Scripts](https://github.com/SU-SWS/stanford_travisci_scripts)
Repository of scripts used by Travis CI to build sites and test feature modules.
##### Version: 7.x-1.0

Maintainers: [sherakama](https://github.com/sherakama), [kbrownell](https://github.com/kbrownell)

[Changelog.txt](CHANGELOG.txt)

[TravisCI](https://travis-ci.org/) is a testing tool that automatically builds a site and runs through a suite of tests.  Any time someone creates a pull request in GitHub, Travis will run through our behat tests for that feature and return whether the code changes pass or fail.  A log of behat test results can also be reviewed for additional details on how and what failed.

We chose to keep our .travis.yml file as minimal as possible, so that we can more easily maintain and update this code across a number of different repositories.

Sites are built and tests are run by scripts in the bin directory.  These scripts assume that the Behat test name will match the module name it tests.  For example, if the module is stanford_bean_types, then before_script.sh will assume the Behat test name will be stanford_bean_types.feature.  Our full suite of tests can be found in the [Linky Click](https://github.com/SU-SWS/linky_clicky) repository.

Installation
---

1. To add TravisCI to a repository, first create an account by logging in with GitHub at [travis-ci.org](https://travis-ci.org/).
2. Go to your profile page at [travis-ci.org/profile](https://travis-ci.org/profile).
3. Click on Stanford Web Services under Organizations.
3. Find the name of your repository and click the toggle switch on.
4. Then click the gear wheel.  This will take you to settings for this repository.
5. Our builds rely on a custom Environment Variable.  Under Name, enter `TEST_FEATURE` and under Value, enter the name of this repository, ie. `stanford_bean_types`.
6. Disable Build pushes, so that Travis CI will only build and run tests on pull requests.
6. Now, in a localy copy of the repository, create a travisci-test branch.
7. Add the .travis.default.yml file to your repository and rename it .travis.yml.
8. Save and commit this file to your travisci-test branch.
9. In the GitHub GUI, create a pull request to merge travisci-test.  This should trigger a site build in TravisCI.
11. 2-6 minutes later, check back to see whether your tests succeeded.
12. The test results should give you the option to view more details.
13. This will take you back to travis-ci.org, where you can review the build and test logs.

Setting up a Local Copy of Travis CI
---

1. Follow the instructions under [Running a Container Based Docker Image Locally](https://docs.travis-ci.com/user/common-build-problems/#Running-a-Container-Based-Docker-Image-Locally), however use travis-php instead of travis-ruby, ie. `docker run -it quay.io/travisci/travis-php /bin/bash`.
2. In your docker image, run (taken from http://stackoverflow.com/questions/29753560/how-to-reproduce-a-travis-ci-build-environment-for-debugging/38804734#38804734):
```
# Install a recent ruby (default is 1.9.3)
rvm install 2.3.0
rvm use 2.3.0

# Install travis-build to generate a .sh out of .travis.yml
cd builds
git clone https://github.com/travis-ci/travis-build.git
cd travis-build
gem install travis
travis # to create ~/.travis
ln -s `pwd` ~/.travis/travis-build
bundle install

# Create project dir, assuming your project is `me/project` on GitHub
cd ~/builds
mkdir me
cd me
git clone https://github.com/me/project.git
cd project
# change to the branch or commit you want to investigate
travis compile > ci.sh
# You most likely will need to edit ci.sh as it ignores matrix and env
bash ci.sh
```
I found that I had to add a branch value to this line:
`travis_cmd git\ clone\ --depth\=50\ --branch\=\'travisci-test\'\ https://github.com/SU-SWS/stanford_gallery.git\ SU-SWS/stanford_gallery --assert --echo --retry --timing`

And remove lines related to phpenv, in order for the compiled script to run .travis.yml.

Assets
---

**.htaccess:** This is a copy of Drupal's 7.50 .htaccess file with RewriteBase / uncommented.

**aliases.drushrc.php:** Behat uses drush aliases to run a number of test.

**behat.yml:** Behat expects this file to be present and contain information about the default site url and drush alias it should use.

**bin/before_install.sh:** Script that downloads required packages for building sites and running tests, such as drush, behat, selenium, etc.

**bin/install.sh:** Script that builds a self-service, department site based on our [Stanford Drupal Profile](https://github.com/SU-SWS/Stanford-Drupal-Profile) make files.  It also starts the webserver and webdrivers we'll be using to run behat tests in a display-less environment.

**bin/before_script.sh:** Script that downloads our test suite [Linky Clicky](https://github.com/SU-SWS/linky_clicky.git) and copies over tests for the feature we are testing.  It also starts xvfb, which we use to fake a display.

**composer.json:** Contains the packages we need to build and test sites, such as drush, behat, selenium, etc.

**features/:** This directory, and more importantly, the contents of features/bootstrap include the custom step definitions which we use to run our behat tests.

**includes/:** As with features/bootstrap, this directory includes the minimum files we need from Linky Clicky to run behat tests.

Contribution / Collaboration
---

You are welcome to contribute functionality, bug fixes, or documentation to this module. If you would like to suggest a fix or new functionality you may add a new issue to the GitHub issue queue or you may fork this repository and submit a pull request. For more help please see [GitHub's article on fork, branch, and pull requests](https://help.github.com/articles/using-pull-requests)
