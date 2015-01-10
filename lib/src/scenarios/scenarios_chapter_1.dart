part of kara.scenarios;

Scenario scenario101() {
  return new Scenario(
      title: 'Kara 1.01 - First Steps',
      width: 10,
      height: 10,
      karaDirection: directionRight,
      actors: r'''

@# # #.
''');
}

Scenario scenario108() {
  return new Scenario(
      title: 'Kara 1.08 - Around Tree With Method',
      width: 10,
      height: 10,
      karaDirection: directionRight,
      actors: r'''




@ * # # #.
''');
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