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

String gqlGetTemplateNames() {
  return """
  query {
    templates {
      id
      name
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

String gqlPossibleStationPorts() {
  return """
  query {
    stationPorts
  }
  """;
}

String gqlUpdatePlant() {
  return """
  mutation(\$id: ID!, \$stationID: ID!, \$input: PlantInput!) {
    updatePlant(id: \$id, stationID: \$stationID, input: \$input) {
      id
    }
  }
  """;
}

String gqlCreatePlant() {
  return """
  mutation(\$stationID: ID!, \$input: PlantInput!) {
    createPlant(stationID: \$stationID, input: \$input) {
      id
    }
  }
  """;
}

String gqlDeletePlant() {
  return """
  mutation(\$id: ID!) {
    deletePlant(id: \$id)
  }
  """;
}
