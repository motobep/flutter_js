/*
 * @Description: isolate
 * @Author: ekibun
 * @Date: 2020-10-02 13:49:03
 * @LastEditors: ekibun
 * @LastEditTime: 2020-10-03 22:21:31
 */
part of './quickjs_runtime2.dart';

typedef dynamic _Decode(Map obj);
List<_Decode> _decoders = [
  JSError._decode,
  IsolateFunction._decode,
];

abstract class _IsolateEncodable {
  Map _encode();
}

dynamic _encodeData(dynamic data, {Map<dynamic, dynamic>? cache}) {
  if (cache == null) cache = Map();
  if (cache.containsKey(data)) return cache[data];
  if (data is Error || data is Exception)
    return _encodeData(JSError(data), cache: cache);
  if (data is _IsolateEncodable) return data._encode();
  if (data is List) {
    final ret = [];
    cache[data] = ret;
    for (int i = 0; i < data.length; ++i) {
      ret.add(_encodeData(data[i], cache: cache));
    }
    return ret;
  }
  if (data is Map) {
    final ret = {};
    cache[data] = ret;
    for (final entry in data.entries) {
      ret[_encodeData(entry.key, cache: cache)] =
          _encodeData(entry.value, cache: cache);
    }
    return ret;
  }
  if (data is Future) {
    final futurePort = ReceivePort();
    data.then((value) {
      futurePort.first.then((port) {
        futurePort.close();
        (port as SendPort).send(_encodeData(value));
      });
    }, onError: (e) {
      futurePort.first.then((port) {
        futurePort.close();
        (port as SendPort).send({#error: _encodeData(e)});
      });
    });
    return {
      #jsFuturePort: futurePort.sendPort,
    };
  }
  return data;
}

dynamic _decodeData(dynamic data, {Map<dynamic, dynamic>? cache}) {
  if (cache == null) cache = Map();
  if (cache.containsKey(data)) return cache[data];
  if (data is List) {
    final ret = [];
    cache[data] = ret;
    for (int i = 0; i < data.length; ++i) {
      ret.add(_decodeData(data[i], cache: cache));
    }
    return ret;
  }
  if (data is Map) {
    for (final decoder in _decoders) {
      final decodeObj = decoder(data);
      if (decodeObj != null) return decodeObj;
    }
    if (data.containsKey(#jsFuturePort)) {
      SendPort port = data[#jsFuturePort];
      final futurePort = ReceivePort();
      port.send(futurePort.sendPort);
      final futureCompleter = Completer();
      futureCompleter.future.catchError((e) {});
      futurePort.first.then((value) {
        futurePort.close();
        if (value is Map && value.containsKey(#error)) {
          futureCompleter.completeError(_decodeData(value[#error]));
        } else {
          futureCompleter.complete(_decodeData(value));
        }
      });
      return futureCompleter.future;
    }
    final ret = {};
    cache[data] = ret;
    for (final entry in data.entries) {
      ret[_decodeData(entry.key, cache: cache)] =
          _decodeData(entry.value, cache: cache);
    }
    return ret;
  }
  return data;
}

