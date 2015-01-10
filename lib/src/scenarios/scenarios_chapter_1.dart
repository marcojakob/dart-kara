part of kara.scenarios;

Scenario scenario04a() {
  return new Scenario(
      title: '04a Around Tree II',
      width: 10,
      height: 2,
      actors: r'''

@# # #.
''',
      karaDirection: directionRight);
}

Scenario scenario04b() {
  return new Scenario(
      title: '04b Around Tree II',
      width: 20,
      height: 2,
      actors: r'''

@ .. # # #.
''',
      karaDirection: directionRight);
}

Scenario scenario04c() {
  return new Scenario(
      title: '04c Around Tree II',
      width: 10,
      height: 2,
      actors: r'''

@  # # #.#
''',
      karaDirection: directionRight);
}

Scenario scenario08a() {
  return new Scenario(
      title: '08a Kara As Guard',
      width: 9,
      height: 9,
      actors: r'''

    ####
   #...#
  #....#
@#.....#
  #..##
 #..#
  ###
''',
      karaDirection: directionUp);
}