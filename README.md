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

Instructions coming soon.

Assets
---

**.htaccess:** This is a copy of Drupal's 7.50 .htaccess file with RewriteBase / uncommented.

**aliases.drushrc.php:** Behat uses drush aliases to run a number of test.

**behat.yml:** Behat expects this file to be present and contain information about the default site url and drush alias it should use.

Contribution / Collaboration
---

You are welcome to contribute functionality, bug fixes, or documentation to this module. If you would like to suggest a fix or new functionality you may add a new issue to the GitHub issue queue or you may fork this repository and submit a pull request. For more help please see [GitHub's article on fork, branch, and pull requests](https://help.github.com/articles/using-pull-requests)
