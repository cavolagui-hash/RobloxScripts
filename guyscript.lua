#include <iostream>
#include <string>

using namespace std;

void espOponente() {
    cout << "ESP OPONENTE ATIVADO" << endl;
    cout << "Linha acima da cabeca do inimigo ativada." << endl;
}

void espBox() {
    cout << "ESP BOX ATIVADO" << endl;
    cout << "Caixa ao redor do oponente ativada." << endl;
}

int main() {

    string senha;

    cout << "=== WAKEZINN VIP LOGIN ===" << endl;
    cout << "Digite a senha: ";
    cin >> senha;

    if (senha != "wakevip777") {
        cout << "Senha incorreta!" << endl;
        return 0;
    }

    int opcao;

    while (true) {

        cout << endl;
        cout << "==== WAKEZINN VIP ====" << endl;
        cout << "1 - ESP OPONENTE" << endl;
        cout << "2 - ESP BOX" << endl;
        cout << "3 - SAIR" << endl;
        cout << "Escolha: ";
        cin >> opcao;

        switch (opcao) {

            case 1:
                espOponente();
                break;

            case 2:
                espBox();
                break;

            case 3:
                cout << "Saindo..." << endl;
                return 0;

            default:
                cout << "Opcao invalida!" << endl;
        }
    }

    return 0;
}

