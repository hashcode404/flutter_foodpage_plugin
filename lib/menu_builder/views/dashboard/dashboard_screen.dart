import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foodpage_plugin/menu_builder/core/constants/menu_builder_theme.dart';
import 'package:flutter_foodpage_plugin/menu_builder/core/utils/ui_utils.dart';
import 'package:flutter_foodpage_plugin/menu_builder/views/common/header/header_widget.dart';
import 'package:flutter_foodpage_plugin/menu_builder/views/common/side_menu/side_menu_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: menuBuilderTheme(context),
      child: const Scaffold(
        body: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SideMenuWidget(),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    HeaderWidget(),
                    verticalSpaceRegular,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading:
                                    Icon(FluentIcons.food_20_regular),
                                title: Text("Total Products"),
                                subtitle: Text("300"),
                              ),
                            ),
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  FluentIcons.apps_list_20_regular,
                                ),
                                title: Text("Total Categories"),
                                subtitle: Text("10"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    verticalSpaceSmall,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: Icon(FluentIcons.food_20_regular),
                                title: Text("Total Menus"),
                                subtitle: Text("4"),
                              ),
                            ),
                          ),
                          horizontalSpaceSmall,
                          Expanded(
                            child: Card(
                              child: ListTile(
                                leading: Icon(
                                  FluentIcons.apps_add_in_20_regular,
                                ),
                                title: Text("Total Modifiers"),
                                subtitle: Text("8"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
