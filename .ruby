---
source:
- ruby.yml
authors:
- name: Trans
  email: transfire@gmail.com
copyrights:
- holder: Rubyworks
  year: '2006'
  license: BSD-2-Clause
replacements: []
alternatives: []
requirements:
- name: facets
  version: ! '>=2.4.3'
- name: finder
- name: detroit
  groups:
  - build
  development: true
- name: ronn
  groups:
  - build
  development: true
- name: qed
  groups:
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
- name: lemon
  groups:
  - test
  development: true
dependencies: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/quarry.git
  scm: git
  name: upstream
resources:
  home: https://rubyworks.github.com/quarry
  code: https://github.com/rubyworks/quarry
  bugs: https://github.com/rubyworks/quarry/issues
  wiki: https://github.com/rubyworks/quarry/wiki
  gem: http://rubygems.org/gems/quarry
extra: {}
load_path:
- lib
revision: 0
name: quarry
title: Quarry
version: 0.1.0
summary: Rock-solid file scaffolding
created: '2009-10-17'
description: Quarry is a flexible and straight-forward file scaffolding system.
organization: rubyworks
date: '2012-02-13'
