import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class ScreenDetil extends StatelessWidget {
  const ScreenDetil({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' Detil '),
      ),
      body: BlocBuilder<DetilJenisPinjamanCubit, DetilJenisPinjamanModel>(
        builder: (context, detilPinjaman) {
          return Column(
            children: [
              Text("id: ${detilPinjaman.id}"),
              Text("nama: ${detilPinjaman.nama}"),
              Text("bunga: ${detilPinjaman.bunga}"),
              Text("Syariah: ${detilPinjaman.isSyariah}"),
            ],
          );
        },
      ),
    );
  }
}

class DetilJenisPinjamanModel {
  final String id;
  final String nama;
  final String bunga;
  final String isSyariah;

  DetilJenisPinjamanModel({
    required this.id,
    required this.nama,
    required this.bunga,
    required this.isSyariah,
  });
}

class DetilJenisPinjamanCubit extends Cubit<DetilJenisPinjamanModel> {
  final String url = "http://178.128.17.76:8000/detil_jenis_pinjaman/";

  DetilJenisPinjamanCubit()
      : super(DetilJenisPinjamanModel(
            id: '', nama: '', bunga: '', isSyariah: ''));

  void setFromJson(Map<String, dynamic> json) {
    emit(DetilJenisPinjamanModel(
      id: json["id"],
      nama: json["nama"],
      bunga: json["bunga"],
      isSyariah: json["is_syariah"],
    ));
  }

  void fetchData(String id) async {
    final response = await http.get(Uri.parse("$url$id"));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<JenisPinjamanCubit>(
            create: (BuildContext context) => JenisPinjamanCubit(),
          ),
          BlocProvider<DetilJenisPinjamanCubit>(
            create: (BuildContext context) => DetilJenisPinjamanCubit(),
          ),
        ],
        child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' My App P2P '),
      ),
      body: Center(
        child: BlocBuilder<JenisPinjamanCubit, JenisPinjamanModel>(
          builder: (context, jenisPinjaman) {
            List<DropdownMenuItem<String>> jenis = [
              const DropdownMenuItem<String>(
                value: "0",
                child: Text("Pilih jenis pinjaman"),
              ),
              const DropdownMenuItem<String>(
                value: "1",
                child: Text("Jenis pinjaman 1"),
              ),
              const DropdownMenuItem<String>(
                value: "2",
                child: Text("Jenis pinjaman 2"),
              ),
              const DropdownMenuItem<String>(
                value: "3",
                child: Text("Jenis pinjaman 3"),
              ),
            ];

            return Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "nim1,nama1; nim2,nama2; Saya berjanji tidak akan berbuat curang data atau membantu orang lain berbuat curang",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: DropdownButton(
                    value: jenisPinjaman.strPilihanJenis,
                    items: jenis,
                    onChanged: (String? newValue) {
                      if ((newValue != null) && (newValue != "0")) {
                        context.read<JenisPinjamanCubit>().fetchData(newValue);
                      }
                    },
                  ),
                ),
                BlocBuilder<DetilJenisPinjamanCubit, DetilJenisPinjamanModel>(
                  builder: (context, detilPinjaman) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: jenisPinjaman.dataPinjaman.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              context.read<DetilJenisPinjamanCubit>().fetchData(
                                  jenisPinjaman.dataPinjaman[index].id);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ScreenDetil();
                              }));
                            },
                            leading: const Image(
                              image: NetworkImage(
                                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-2.jpg'),
                            ),
                            trailing: const Icon(Icons.more_vert),
                            title: Text(jenisPinjaman.dataPinjaman[index].nama),
                            subtitle: Text(
                                " id: ${jenisPinjaman.dataPinjaman[index].id}"),
                            tileColor: Colors.white70,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class JenisPinjaman {
  final String id;
  final String nama;

  JenisPinjaman({required this.id, required this.nama});
}

class JenisPinjamanModel {
  final String strPilihanJenis;
  final List<JenisPinjaman> dataPinjaman;

  JenisPinjamanModel(
      {required this.dataPinjaman, required this.strPilihanJenis});
}

class JenisPinjamanCubit extends Cubit<JenisPinjamanModel> {
  final String url = "http://178.128.17.76:8000/jenis_pinjaman/";

  JenisPinjamanCubit()
      : super(JenisPinjamanModel(dataPinjaman: [], strPilihanJenis: "0"));

  void setFromJson(Map<String, dynamic> json, String jenis) {
    var arrData = json["data"];
    List<JenisPinjaman> arrOut = [];
    for (var el in arrData) {
      arrOut.add(JenisPinjaman(id: el["id"], nama: el["nama"]));
    }
    emit(JenisPinjamanModel(dataPinjaman: arrOut, strPilihanJenis: jenis));
  }

  void fetchData(String jenis) async {
    final response = await http.get(Uri.parse("$url$jenis"));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body), jenis);
    } else {
      throw Exception('Gagal load');
    }
  }
}
