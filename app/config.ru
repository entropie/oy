require 'rubygems'

Ramaze.start!
require 'app'  

Ramaze.trait[:essentials].delete Ramaze::Adapter  
Ramaze.start  

run Ramaze::Adapter::Base


