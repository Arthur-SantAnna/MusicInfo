#!/bin/bash

# Função para mostrar a caixa de diálogo e pegar o link da música
get_spotify_link() {
    dialog --inputbox "Digite o link da música do Spotify:" 8 40 2> link.txt
    SPOTIFY_LINK=$(<link.txt)
    rm link.txt
}

# Função para baixar a página HTML usando o Lynx
download_html() {
    lynx -source "$SPOTIFY_LINK" > spotify_music_page.html
}

# Função para extrair informações do HTML
extract_info() {
    TITLE=$(grep -oP '(?<=<meta property="og:title" content=").*?(?=")' spotify_music_page.html)
    ARTIST=$(grep -oP '(?<=<meta name="music:musician_description" content=").*?(?=")' spotify_music_page.html)
    ALBUM=$(grep -oP '(?<=<span data-encore-id="type" class="Type__TypeElement-sc-goli3j-0 dsbIME">).*?(?=</span>)' spotify_music_page.html | sed -n '1p')
    YEAR=$(grep -oP '(?<=<span data-encore-id="type" class="Type__TypeElement-sc-goli3j-0 dsbIME">).*?(?=</span>)' spotify_music_page.html | sed -n '2p')
    DURATION=$(grep -oP '(?<=<span data-encore-id="type" class="Type__TypeElement-sc-goli3j-0 dsbIME">).*?(?=</span>)' spotify_music_page.html | sed -n '3p')
}

# Função para mostrar as informações extraídas
show_info() {
    INFO="Título: $TITLE\nArtista: $ARTIST\nDuração: $DURATION\nÁlbum: $ALBUM\nAno: $YEAR"
    dialog --title "INFORMAÇÕES DA MÚSICA ESCOLHIDA" --msgbox "$INFO" 15 50
    --ok-label "Concluir"
    clear
}

# Função principal
main() {
    get_spotify_link
    download_html
    
    dialog --yesno "Deseja extrair as informações da página baixada?" 7 40
    response=$?
    if [ $response -eq 0 ]; then
        extract_info
        show_info
    else
        dialog --msgbox "Operação cancelada." 5 30
    fi
}

# Executa a função principal
main
