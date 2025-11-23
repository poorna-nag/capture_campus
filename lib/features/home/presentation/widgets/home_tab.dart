import 'package:capture_campus/features/home/presentation/bloc/home_bloc.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_event.dart';
import 'package:capture_campus/features/home/presentation/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    context.read<HomeBloc>().add(HomeLoadingEvent());
    super.initState();
  }

  // final String eventName = '';
  // final String eventInfo = '';
  // final String userName = '';
  // final String? dat = '';
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoadingState) {
          return Center(child: CircularProgressIndicator());
        } else if (state is HomeloadedState) {
          return SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: GoogleFonts.abrilFatface(
                                fontWeight: FontWeight.w500,
                                fontSize: 30,
                                color: Colors.white,
                                shadows: [Shadow(blurRadius: 10)],
                              ),
                              children: [
                                TextSpan(text: "Let's share \n your "),
                                TextSpan(
                                  text: "moment",
                                  style: TextStyle(color: Colors.amberAccent),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.notifications_rounded,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              height: 50,
                              width: 200,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color: Colors.amberAccent,
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                "Capture Event",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              context.read<HomeBloc>().add(UploadEvent());
                            },
                            child: Container(
                              height: 50,
                              width: 200,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color: Colors.amberAccent,
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                "Upload Event",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Recent uploads', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 20),
                    // BlocBuilder(
                    //   builder: (context, state) {

                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is Error) {
          return Text(state.toString());
        } else if (state is GetEventInfoState) {
          if (state.eventInfo.isEmpty) {
            return Text('No Event Added');
          }
          Expanded(
            child: ListView.builder(
              itemCount: state.eventInfo.length,
              itemBuilder: (context, index) {
                final event = state.eventInfo[index];
                return Card(
                  child: Row(
                    children: [Text(event.eventName), Text(event.date)],
                  ),
                );
              },
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
