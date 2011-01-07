require 'rubygems'

load "start.rb"

Ramaze.trait[:essentials].delete(Ramaze::Adapter)

Ramaze.start!

run Ramaze::Adapter::Base
