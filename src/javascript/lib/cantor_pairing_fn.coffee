# Cantor's pairing function: 
# http://stackoverflow.com/questions/919612/mapping-two-integers-to-one-in-a-unique-and-deterministic-way
#   (Explains how to use bijection to let cantor's pairing fn work in negatives)
#
# https://en.wikipedia.org/wiki/Pairing_function#Cantor_pairing_function
#  For more info, like how to do polynomial pairings and how to invert cantor
#
cantor = (k1,k2) ->
  (1 / 2) * (k1 + k2) * (k1 + k2 + 1) + k2


biject = (n) ->
  if n >= 0
   n * 2
  else
   -n * 2 - 1

bijectedCantor = (z1,z2) -> cantor(biject(z1),biject(z2))

module.exports = bijectedCantor
