

import 'package:flutter/material.dart';
import 'package:self_made_app/color_theme/app_color.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder( 
        builder: (context, constraints) {
          return SingleChildScrollView( 
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // ==================== 頂部區域 ====================
                    DrawerHeader(
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.person),
                            SizedBox(width: 8),
                            Text('紀錄你消費', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                    
                    // ==================== 第一個項目 ====================
                    ListTile(
                      leading: const Icon(Icons.monetization_on),
                      title: const Text('本地日常消費'),
                      onTap: () {
                        if (ModalRoute.of(context)?.settings.name == '/home_page' ||
                            ModalRoute.of(context)?.settings.name == '/') {
                          Navigator.pop(context);
                        } else {
                          Navigator.popAndPushNamed(context, '/home_page');
                        }
                      },
                    ),
                    const SizedBox(height: 10),
            
                    // ==================== 第二個項目 ====================
                    ListTile(
                      leading: const Icon(Icons.flight_takeoff),
                      title: const Text('海外旅遊消費'),
                      onTap: () {
                        if (ModalRoute.of(context)?.settings.name == '/travel_page') {
                          Navigator.pop(context);
                        } else {
                          Navigator.popAndPushNamed(context, '/travel_page');
                        }
                      },
                    ),
                    
                    const Spacer(),
                    
                    // ==================== 第三個項目 (貼底) ====================
                    const Divider(height: 1),
                    SafeArea(
                      top: false,
                      child: ListTile(
                        leading: const Icon(Icons.download),
                        title: const Text('數據管理'),
                        onTap: () {
                          if (ModalRoute.of(context)?.settings.name == '/backup_page') {
                            Navigator.pop(context);
                          } else {
                            Navigator.popAndPushNamed(context, '/backup_page');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      
    );
  }
}