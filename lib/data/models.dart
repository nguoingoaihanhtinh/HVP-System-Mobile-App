class Exercise {
  final String icon, name, sub;
  const Exercise(this.icon, this.name, this.sub);
}

class Challenge {
  final String icon, name, desc;
  final int pts;
  const Challenge(this.icon, this.name, this.desc, this.pts);
}

class Notice {
  final String icon, title, body, time;
  const Notice(this.icon, this.title, this.body, this.time);
}
