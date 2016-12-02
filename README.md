# logic

* [Homepage](https://rubygems.org/gems/logic)
* [Documentation](http://rubydoc.info/gems/logic/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//logic/badges/gpa.svg)](https://codeclimate.com/github//logic)

## Description

Logic is a logic programming framework for Ruby.

## Features

* Symbolic logic
* Very simple SAT solver

## Examples

    require 'logic'

    include Logic
    prelude!                    # => [:a, :b, :c, :d, :t, :u, :v, :w, :x, :y, :z]

    # construct logical propositions algebraically

    expr = (a ^ -b) | (a > b)   # => (a and not b) or (a then b)

    # find solutions

    expr.solve
    # => [{:a=>true, :b=>true},
    #     {:a=>true, :b=>false},
    #     {:a=>false, :b=>true},
    #     {:a=>false, :b=>false}]

    # simplify
    ((a > b) ^ a).reduce
    # => b

## Requirements

  Ruby 2.x

## Install

    $ gem install logic
    [...gem installation...]

## Synopsis

    $ logic
    [...interactive environment, wip...]

## Copyright

Copyright (c) 2016 Joseph Weissman

See {file:LICENSE.txt} for details.
