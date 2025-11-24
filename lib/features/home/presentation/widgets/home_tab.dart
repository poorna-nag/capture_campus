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
    super.initState();
    context.read<HomeBloc>().add(HomeLoadingEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const HomeView(),
                  const SizedBox(height: 20),

                  if (state is GetEventInfoState)
                    state.eventInfo.isEmpty
                        ? const Text(
                            "No Event Added",
                            style: TextStyle(color: Colors.white),
                          )
                        : ListView.builder(
                            itemCount: state.eventInfo.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final event = state.eventInfo[index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.grey.shade900,
                                  child: ListTile(
                                    leading: SizedBox(
                                      width: 30,
                                      child: Icon(Icons.image),
                                    ),
                                    title: Text(
                                      event.eventName,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      event.date,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  children: const [
                    TextSpan(text: "Let's share \n your "),
                    TextSpan(
                      text: "moment",
                      style: TextStyle(color: Colors.amberAccent),
                    ),
                  ],
                ),
              ),
              Icon(Icons.notifications_rounded, size: 35, color: Colors.white),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _actionButton("Capture Event", () {
                  context.read<HomeBloc>().add(OpenCameraEvent());
                }),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _actionButton("Upload Event", () {
                  context.read<HomeBloc>().add(UploadEvent());
                }),
              ),
            ],
          ),

          const SizedBox(height: 30),
          const Text(
            'Recent uploads',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 180,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Colors.amberAccent, width: 2),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
