class Secret {
  final String resultsEndpointKey;
  final String rankingEndpointKey;

  Secret({this.rankingEndpointKey = "", this.resultsEndpointKey = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return new Secret(
        rankingEndpointKey: jsonMap["RankingEndpointKey"],
        resultsEndpointKey: jsonMap["ResultsEndpointKey"]);
  }
}
