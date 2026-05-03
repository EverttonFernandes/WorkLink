#!/bin/sh
set -eu

flutter pub get

if ! find integration_test -type f -name '*_test.dart' | grep -q .; then
  echo 'N/A: testes de integracao mobile ainda nao foram criados.'
  exit 0
fi

if flutter devices | grep -Eiq 'android|ios|chrome'; then
  flutter test integration_test
  exit 0
fi

echo 'N/A: testes de integracao mobile exigem Android Emulator, iOS Simulator ou Chrome disponivel.'
