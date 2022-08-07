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

String gqlCreateTemplate() {
  return """
  mutation(\$input: PlantTemplateInput!) {
    createPlantTemplate(input: \$input) {
      id
    }
  }
  """;
}

String gqlUpdateTemplate() {
  return """
  mutation(\$id: ID!, \$input: PlantTemplateInput!) {
    updatePlantTemplate(id: \$id, input: \$input) {
      id
    }
  }
  """;
}

String gqlGetStations() {
  return """
  query {
    stations {
      id
      name
      waterLevel
      plants {
        id
        active
        name
        port
        template {
          id
          name
          waterThreshold
        }
      }
    }
  }
  """;
}

String gqlUpdateStation() {
  return """
  mutation(\$id: ID!, \$input: StationInput!) {
    updateStation(id: \$id, input: \$input) {
      name
    }
  }
  """;
}
