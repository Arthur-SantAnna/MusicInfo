#!/bin/bash
#ARTHUR SANT'ANNA DE CARVALHO SANTOS#
# Pegando link da música
get_spotify_link() {
    dialog --inputbox "Digite o link da música do Spotify:" 8 40 2> link.txt
    SPOTIFY_LINK=$(<link.txt)
    rm link.txt
}

# Baixar a página HTML usando o Lynx
download_html() {
    lynx -source "$SPOTIFY_LINK" > spotify_music_page.html
}

# Extrair informações do HTML
extract_info() {
    TITLE=$(grep -oP '(?<=<meta property="og:title" content=").*?(?=")' spotify_music_page.html)
    ARTIST=$(grep -oP '(?<=<meta name="music:musician_description" content=").*?(?=")' spotify_music_page.html)
    ALBUM=$(grep -oP '(?<=<span data-encore-id="type" class="Type__TypeElement-sc-goli3j-0 dsbIME">).*?(?=</span>)' spotify_music_page.html | sed -n '1p')
    YEAR=$(grep -oP '(?<=<span data-encore-id="type" class="Type__TypeElement-sc-goli3j-0 dsbIME">).*?(?=</span>)' spotify_music_page.html | sed -n '2p')
    DURATION=$(grep -oP '(?<=<span data-encore-id="type" class="Type__TypeElement-sc-goli3j-0 dsbIME">).*?(?=</span>)' spotify_music_page.html | sed -n '3p')
    CLEANED_TITLE=$(echo $TITLE | sed 's/ /_/g')
}

# Informações extraídas
show_info() {
    INFO="\n\nTítulo: $TITLE\nArtista: $ARTIST\nDuração: $DURATION\nÁlbum: $ALBUM\nAno: $YEAR"
    dialog --title "INFORMAÇÕES DA MÚSICA ESCOLHIDA" --msgbox "$INFO" 15 50
    --ok-label "Concluir"
}

# backup do arquivo HTML e das informações extraídas
create_backup() {
    dialog --infobox "Criando backup dos arquivos..." 8 40
    sleep 2
    cp spotify_music_page.html "spotify_$CLEANED_TITLE.html"
    echo -e "Título: $TITLE\nArtista: $ARTIST\nDuração: $DURATION\nÁlbum: $ALBUM\nAno: $YEAR" > "info_$CLEANED_TITLE.txt"
    echo -e "Link do Spotify: $SPOTIFY_LINK" >> "info_$CLEANED_TITLE.txt"
    zip -r "backup_$CLEANED_TITLE.zip" "spotify_$CLEANED_TITLE.html" "info_$CLEANED_TITLE.txt"
    if [ -d backups ]; then
        mv "backup_$CLEANED_TITLE.zip" backups/
    else
        mkdir backups
        mv "backup_$CLEANED_TITLE.zip" backups/
    fi
    rm spotify_music_page.html "info_$CLEANED_TITLE.txt" "spotify_$CLEANED_TITLE.html"
    dialog --msgbox "Backup criado com sucesso!" 5 30 --ok-label "Finalizar"
    clear
}

main() {
    get_spotify_link
    download_html
    
    dialog --yesno "Deseja extrair as informações da página baixada?" 7 40
    response=$?
    if [ $response -eq 0 ]; then
        extract_info
        show_info
        create_backup
    else
        dialog --msgbox "Operação cancelada." 5 30
    fi
}

main
