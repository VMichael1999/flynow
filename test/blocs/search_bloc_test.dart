import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flynow/features/search/data/airport_catalog.dart';
import 'package:flynow/features/search/domain/search_domain.dart';
import 'package:flynow/features/search/presentation/search_bloc.dart';

void main() {
  group('SearchBloc', () {
    blocTest<SearchBloc, SearchState>(
      'arranca en Lima → Los Ángeles',
      build: () => SearchBloc(searchDelay: Duration.zero),
      verify: (b) {
        expect(b.state.origin, lim);
        expect(b.state.destination, lax);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'elige otro origen y otro destino',
      build: () => SearchBloc(searchDelay: Duration.zero),
      act:
          (b) =>
              b
                ..add(const OriginSelected(hnd))
                ..add(const DestinationSelected(mad)),
      verify: (b) {
        expect(b.state.origin, hnd);
        expect(b.state.destination, mad);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'elegir como origen el destino actual los intercambia',
      build: () => SearchBloc(searchDelay: Duration.zero),
      act: (b) => b.add(const OriginSelected(lax)),
      verify: (b) {
        expect(b.state.origin, lax);
        expect(b.state.destination, lim);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'intercambia origen y destino',
      build: () => SearchBloc(searchDelay: Duration.zero),
      act: (b) => b.add(const AirportsSwapped()),
      verify: (b) {
        expect(b.state.origin, lax);
        expect(b.state.destination, lim);
        expect(b.state.swapTurns, 1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'dos intercambios devuelven la ruta original',
      build: () => SearchBloc(searchDelay: Duration.zero),
      act:
          (b) =>
              b
                ..add(const AirportsSwapped())
                ..add(const AirportsSwapped()),
      verify: (b) {
        expect(b.state.origin, lim);
        expect(b.state.destination, lax);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'cambia el tipo de viaje',
      build: () => SearchBloc(searchDelay: Duration.zero),
      act: (b) => b.add(const TripTypeSelected(TripType.roundTrip)),
      verify: (b) => expect(b.state.tripType, TripType.roundTrip),
    );

    blocTest<SearchBloc, SearchState>(
      'buscar muestra el overlay y luego avisa que terminó',
      build: () => SearchBloc(searchDelay: Duration.zero),
      act: (b) => b.add(const SearchSubmitted()),
      verify: (b) {
        expect(b.state.searching, isFalse);
        expect(b.state.submissions, 1);
      },
      expect:
          () => [
            isA<SearchState>().having((s) => s.searching, 'searching', true),
            isA<SearchState>()
                .having((s) => s.searching, 'searching', false)
                .having((s) => s.submissions, 'submissions', 1),
          ],
    );
  });
}
