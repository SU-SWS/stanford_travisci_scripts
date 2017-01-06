#!/bin/bash

# before_install
composer self-update
phpenv rehash
composer install
