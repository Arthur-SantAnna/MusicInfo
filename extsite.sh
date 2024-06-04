#!/bin/bash

# Função para exibir a tela de diálogo e capturar o link do Spotify
get_spotify_link() {
    dialog --title "Link da Música no Spotify" --inputbox "Por favor, insira o link da música no Spotify:" 10 60 2>link.txt

    response=$?
    link=$(<link.txt)
    rm -f link.txt

    if [ $response -eq 0 ]; then
        echo "$link"
    else
        dialog --msgbox "Operação cancelada." 6 40
        exit 1
    fi
}

# Função para baixar o HTML da página
download_html() {
    local url=$1
    local output_file="spotify_page.html"

    lynx -source "$url" > "$output_file"

    if [ $? -eq 0 ]; then
        dialog --msgbox "HTML baixado e salvo em $output_file" 6 40
    else
        dialog --msgbox "Erro ao baixar o HTML." 6 40
        exit 1
    fi
}

# Função principal
main() {
    get_spotify_link
    download_html "$link"

    if ask_extract_info; then
        extract_info
    else
        dialog --msgbox "Operação concluída." 6 40
    fi

    clear
}

# Executa a função principal
main
