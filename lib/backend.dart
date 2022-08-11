import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'graphql.dart';

Backend backend = Backend();

class Backend {
  WebSocketLink? wsLink;
  GraphQLClient? gqlClient;
  Function? onDisconnect;

  Backend() {
    if (kIsWeb) {
      String host = Uri.base.host;
      if (Uri.base.port != 80) {
        host += ":" + Uri.base.port.toString();
      }
      wsLink = WebSocketLink('ws://' + host + '/graphql');
      gqlClient = GraphQLClient(
        link: Link.split((request) => request.isSubscription, wsLink!,
            HttpLink('http://' + host + '/graphql')),
        cache: GraphQLCache(),
      );
    }
  }

  Future<bool> pingAddress(String address) async {
    Future<String> ping() async {
      try {
        final response =
            await http.get(Uri.parse('http://' + address + '/ping'));

        if (response.statusCode == 200) {
          return response.body;
        } else {
          return Future<String>(() {
            return "";
          });
        }
      } catch (e) {
        return Future<String>(() {
          return "";
        });
      }
    }

    return await ping() == "pong";
  }

  setAddress(address) {
    wsLink = WebSocketLink('ws://' + address + '/graphql',
        config: SocketClientConfig(connectFn: (uri, protocols) {
      var channel = WebSocketChannel.connect(uri, protocols: protocols);
      channel = channel.forGraphQL();
      channel.stream.listen((data) {}, onDone: () {
        wsLink?.dispose();
        if (onDisconnect != null) {
          onDisconnect!();
        }
      });
      return channel;
    }));
    gqlClient = GraphQLClient(
      link: Link.split((request) => request.isSubscription, wsLink!,
          HttpLink('http://' + address + '/graphql')),
      cache: GraphQLCache(),
    );
  }

  handleResult(QueryResult result, onSuccess) {
    if (result.hasException && result.exception?.linkException != null) {
      wsLink?.dispose();
      if (onDisconnect != null) {
        onDisconnect!();
      }
    } else {
      onSuccess(result);
    }
  }

  getTemplates(onSuccess) {
    gqlClient
        ?.query(QueryOptions(
      document: gql(gqlGetTemplates()),
      fetchPolicy: FetchPolicy.networkOnly,
    ))
        .catchError((error) {
      log('failed to fetch templates',
          name: 'lazypig.graphql', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  getStations(onSuccess) {
    gqlClient
        ?.query(QueryOptions(
      document: gql(gqlGetStations()),
      fetchPolicy: FetchPolicy.networkOnly,
    ))
        .catchError((error) {
      log('failed to fetch stations',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  subscribeStations(onSuccess) {
    var subscription = gqlClient?.subscribe(SubscriptionOptions(
      document: gql(gqlSubscribeStations()),
    ));

    subscription?.listen((result) {
      if (result.isLoading) {
        return;
      }

      handleResult(result, onSuccess);
    });
  }

  getPossiblePorts(onSuccess) {
    gqlClient
        ?.query(QueryOptions(document: gql(gqlPossibleStationPorts())))
        .catchError((error) {
      log('failed to fetch possible station ports',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  getTemplateNames(onSuccess) {
    gqlClient
        ?.query(QueryOptions(
      document: gql(gqlGetTemplateNames()),
      fetchPolicy: FetchPolicy.networkOnly,
    ))
        .catchError((error) {
      log('failed to fetch templates',
          name: 'lazypig.templates', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  updateStation(id, name, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(document: gql(gqlUpdateStation()), variables: {
      'id': id,
      'input': {'name': name}
    }))
        .catchError((error) {
      log('failed to update station',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  updatePlant(variables, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(
            document: gql(gqlUpdatePlant()), variables: variables))
        .catchError((error) {
      log('failed to update plant',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  deletePlant(id, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(
            document: gql(gqlDeletePlant()), variables: {'id': id}))
        .catchError((error) {
      log('failed to delete plant',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  createPlant(variables, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(
            document: gql(gqlCreatePlant()), variables: variables))
        .catchError((error) {
      log('failed to create plant',
          name: 'lazypig.plants', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  deleteTemplates(List<int> ids, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(
            document: gql(gqlDeleteTemplates()), variables: {'ids': ids}))
        .catchError((error) {
      log('failed to delete templates',
          name: 'lazypig.templates', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  createTemplate(variables, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(
            document: gql(gqlCreateTemplate()), variables: variables))
        .catchError((error) {
      log('failed to create template',
          name: 'lazypig.templates', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }

  updateTemplate(variables, onSuccess) {
    gqlClient
        ?.mutate(MutationOptions(
            document: gql(gqlUpdateTemplate()), variables: variables))
        .catchError((error) {
      log('failed to update template',
          name: 'lazypig.templates', error: jsonEncode(error));
    }).then((result) {
      handleResult(result, onSuccess);
    });
  }
}
