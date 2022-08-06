String gqlGetTemplates() {
  return """
  query {
    templates {
      id
      name
      waterThreshold
    }
  } 
  """;
}

String gqlDeleteTemplates() {
  return """
  mutation(\$ids: [ID]!) {
    deletePlantTemplate(ids: \$ids)
  }
  """;
}
