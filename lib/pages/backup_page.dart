import 'package:flutter/material.dart';
import 'package:self_made_app/Boxes/backup_service.dart';
import 'package:self_made_app/Boxes/box_money.dart';
import 'package:self_made_app/component/drawer.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key});

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  bool _loading = false;

  bool _deleting = false;

  Future<void> _exportAndShare() async {
    setState(() => _loading = true);
    try {
      await BackupService.shareBackupFile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('備份檔已匯出並可分享')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('匯出失敗：$e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _importBackup() async {
    setState(() => _loading = true);
    try {
      final result = await BackupService.importBackupFromPicker();

      if(!mounted) return;
      if (result == null) {
        setState(() {
      //    _status = '已取消匯入';
        });
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('資料已成功還原，日常消費${result.moneyCount}筆，旅行消費${result.travelCount}筆')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('還原失敗：$e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
      Navigator.pop(context);
    }
  }


  
  //手動reset hive database
  Future<void> _clearDataBox(String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("確認刪除"),
          content: Text("確定要刪除$type記錄嗎？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () async{
                Navigator.of(context).pop(); // Close confirmation dialog first
                setState(() => _deleting = true);
                try {
                  type == "日常消費" ? 
                  await boxMoneyData.clear():
                  await TravelboxMoneyData.clear();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$type已成功刪除')),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('刪除失敗：$e')),
                  );
                } finally {
                  if (mounted) setState(() => _deleting = false);
                }
              },
              child: Text("刪除", style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('資料備份與還原'),
      ),
      drawer: Drawer(child: MyDrawer(),),
      drawerEdgeDragWidth: 30,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _deleting ? null : _exportAndShare,
                          icon: const Icon(Icons.upload_file,color: Colors.black),
                          label: Text(
                            _loading ? '處理中...' : '匯出並分享備份',
                            style: TextStyle(color: Colors.black),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightGreenAccent[400]
                          )
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _importBackup,
                          icon: const Icon(Icons.download,color: Colors.black,),
                          label: Text(_loading ? '處理中...' : '匯入備份並還原',
                            style: TextStyle(color: Colors.black),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent[400]
                          )
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '匯入會覆蓋目前本機資料，請先確認已備份。',
                        style: TextStyle(color: Colors.red),
                      ),
                      
                      const Spacer(),
                      const Text(
                        '刪除本機資料前請先確認已備份。',
                        style: TextStyle(color: Colors.red),
                      ),                   
                      SizedBox(height: 10,),
                      SafeArea(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            SizedBox(
                              child: ElevatedButton.icon(
                                onPressed: _deleting ? null : () async {await _clearDataBox("日常消費");},
                                icon: const Icon(Icons.delete_forever),
                                label: Text(_deleting ? '處理中...' : '刪除所有日常消費紀錄'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[40]
                                )
                              ),
                            ),
                            
                            SizedBox(
                              child: ElevatedButton.icon(
                                onPressed: _deleting ? null : () async {await _clearDataBox("旅行消費");},
                                icon: const Icon(Icons.delete_forever),
                                label: Text(_deleting ? '處理中...' : '刪除所有旅行消費紀錄'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[300]
                                )
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        
      ),
    );
  }
}