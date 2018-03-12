# _______________________________________________________________________________________________________________
# Dernière mise à jour : 08-02-2018 - 15h00
# _______________________________________________________________________________________________________________
CheminTravail <- "D:/T19QHL/Mes Documents/Appli R/Planpreform/"
# ----------------------------------------
options(shiny.maxRequestSize=100*1024^2)

setwd(paste0(CheminTravail,"Utilisateurs/"))
CheminPkg <- paste0(CheminTravail,"packrat/lib/x86_64-w64-mingw32/3.4.2/")
CheminPgm <- paste0(CheminTravail,"Pgm/")


# Chemin d'accès aux packages sur l'environnement de production ou recette (décommenter/commenter la bonne ligne)
# chemin <- ""  

bibliotheque <- paste0(CheminTravail,"packrat/lib/x86_64-w64-mingw32/3.4.2") #chemin complet vers mon dossier de packages
.libPaths(bibliotheque) #on fixe une variable d'environnement : en gros, il va chercher par défaut les packages dans le chemin bibliotheque
#require(htmltools, lib.loc = CheminPkg)

library(shiny, warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(readODS,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(plyr,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(dplyr,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(tidyr,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(stringr,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(xlsx,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(rChoiceDialogs,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(rmarkdown,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)
library(DT,warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)


Chemin <- jchoose.dir(caption = "Veuillez choisir le chemin de votre répertoire de travail (CNIN ou SINL ...)")
Chemin <- paste0(Chemin,"/")


# _______________________________________________________________________________________________________________
shinyServer(function(input, session, output) {  
  
  mes_donnees <- reactiveFileReader(1000, session, paste0(Chemin,"Donnees/Travail/ListFormation_By_Id.rds"), readRDS)
  donnees_Forma_Autre_Choix <- reactiveFileReader(1000, session, paste0(Chemin,"Donnees/Travail/ListAutChx.rds"), readRDS)
  TabFormation <- reactiveFileReader(1000, session, paste0(Chemin,"Donnees/Travail/TabFormations.rds"), readRDS)
  ListAgents <- reactiveFileReader(600000, session, paste0(Chemin,"Donnees/Travail/BaseAgents.rds"), readRDS)
  
  
  # _______________________________________________________________________________________________________________
  # _______________________________________________________________________________________________________________
  # _______________________________________________________________________________________________________________
  
  Traitement_Sortie_LS <- eventReactive(input$validSortieLs,{
    req(input$ExecutSortie_Ls)
    TabSortie_LS <- read_ods(paste0(Chemin,"Donnees/Inputs/TabSorties_LS.ods"),
                             sheet = 1,
                             col_names = T)
    
    NbColMax <- ncol(TabSortie_LS)
    TabSortie_LS <- TabSortie_LS[,c(1:NbColMax)]
    names(TabSortie_LS)[c(1,2,4)] <- c("Nom","Prenom","Autres Choix")
    
    # _________________________________________________________________________________________________________________________
    # _________________________________________________________________________________________________________________________
    # Fonction pour renommer les variables de formation
    NomsVars <- names(TabSortie_LS)
    NumVars_QuestFormations <- 1:length(TabSortie_LS) # A preciser
    for (i in NumVars_QuestFormations){
      if (is.na(str_locate((NomsVars)[i], "\\[")[[1]])){  
        NomsVars[i] <- NomsVars[i]
      } else if(is.na(str_locate((NomsVars)[i], "]")[[2]])){   
        NomsVars[i] <- NomsVars[i]
      } else {
        DebString <- str_locate((NomsVars)[i], "\\[")                       
        FinString <- str_locate((NomsVars)[i], "]")
        NomsVars[i] <- str_sub((NomsVars)[i],
                               start =DebString[[1]]+1,
                               end = FinString[[1]]-1)
      }
    }
    names(TabSortie_LS) <- NomsVars
    
    # _________________________________________________________________________________________________________________________
    
    BaseAgents <- read_ods(paste0(Chemin,"Donnees/Inputs/BaseAgents.ods"),
                           sheet = 1,
                           col_names = T)
    BaseAgents <- BaseAgents[,c(1:6)]
    names(BaseAgents) <- c("Nom","Prenom","Service Agent","Groupe Agent","Service Sup H","Groupe Sup H")
    BaseAgents[is.na(BaseAgents)] <- "_"
    
    saveRDS(BaseAgents,paste0(Chemin,"Donnees/Travail/BaseAgents.rds"))
    
    
    # Fusion de  la table de résultats Lime Survey avec la table Agent
    Sortie_LS <- merge(TabSortie_LS,BaseAgents,by=c("Nom","Prenom"),all.y=T)
    # !!! certaines colonnes portent le même nom. Pbm résolu avec le gather() puisque la 2ème colonne est automatiquement renommée
    
    # Ordre des variables :Nom, Prénom, Id, services ..., Formations
    Sortie_LS <- Sortie_LS[,c(1:3,(NbColMax+1):(NbColMax+4),4:NbColMax)]
    
    #     Transposition
    ListFormation_By_Id <- gather(Sortie_LS,
                                  key = "Formation",
                                  value = "Desiderata",
                                  8:(NbColMax+4))
    ListFormation_By_Id[is.na(ListFormation_By_Id)] <- "Non"
    
    ListFormation_By_Id$IdAgent <- paste0(ListFormation_By_Id$Nom," ",
                                          ListFormation_By_Id$Prenom," ",
                                          ListFormation_By_Id$`Service Agent`," ",
                                          ListFormation_By_Id$`Groupe Agent`)
    
    ListFormation_By_Id$IdAgentBySupH <- paste0(ListFormation_By_Id$`Service Sup H`," ",
                                                ListFormation_By_Id$`Groupe Sup H`," ",
                                                ListFormation_By_Id$Nom," ",
                                                ListFormation_By_Id$Prenom)
    
    
    # Création de la table "Autres Choix"
    ListAutChx <- ListFormation_By_Id[ListFormation_By_Id$Formation == "Autres Choix",]
    ListAutChx$Etat <- ifelse(ListAutChx$Desiderata =="Non","Non renseigné","A traiter")
    
    
    saveRDS(ListAutChx,paste0(Chemin,"Donnees/Travail/ListAutChx.rds"))
    
    # Création de la table "Formations demandées"
    ListFormation_By_Id <- ListFormation_By_Id[ListFormation_By_Id$Desiderata == "Oui",]
    saveRDS(ListFormation_By_Id,paste0(Chemin,"Donnees/Travail/ListFormation_By_Id.rds"))
    
    # Création de la table des formations
    TabFormations <- read_ods(paste0(Chemin,"Donnees/InPuts/TabFormations.ods"),1)
    # Traitement des formations ayant le même nom
    TabFormations <- TabFormations[order(TabFormations$FORMATIONS,TabFormations$DOMAINES),]
    TabFormations <- ddply(TabFormations, .(FORMATIONS), transform, rng = rank(rank(DOMAINES)))
    TabFormations$FORMATIONS <- ifelse(TabFormations$rng ==1,
                                       TabFormations$FORMATIONS,
                                       paste0(TabFormations$FORMATIONS,".",as.character(TabFormations$rng-1))
    )
    # TabFormations$FORMATIONS <- paste0("- ",substr(TabFormations$DOMAINES,1,6)," - ",TabFormations$FORMATIONS)
    saveRDS(TabFormations,paste0(Chemin,"Donnees/Travail/TabFormations.rds"))
    
    # NomsVars
    names(Sortie_LS)
  })
  
  # _________________________________________________________________________________________________________________________
  
  donnees_Ajout_AutreChoix <- eventReactive(input$validModif,{
    req(input$ChoixAgent, input$ChoixFormation2)
    
    AjoutChoix <- donnees_Forma_Autre_Choix()[,-c(12)]
    BaseTemp <-  AjoutChoix[AjoutChoix$IdAgent %in% input$ChoixAgent,]
    
    BaseTemp[,c("Formation","Desiderata")] <- c(input$ChoixFormation2,"Oui")
    AjoutChoix <- rbind(mes_donnees(),BaseTemp)
    AjoutChoix <- distinct(AjoutChoix)
    
    return(AjoutChoix)
  })
  
  # --------------------------------------------------------------------------------------------------------------
  observeEvent(donnees_Ajout_AutreChoix(),{
    temp <- donnees_Ajout_AutreChoix()
    
    saveRDS(temp,paste0(Chemin,"Donnees/Travail/ListFormation_By_Id.rds"))
  })
  
  # --------------------------------------------------------------------------------------------------------------
  
  # POUR AJOUTER UNE NOUVELLE FORMATION A LA LISTE DES FORMATIONS 
  donnees_Ajout_Formations <- eventReactive(input$ValidAjoutNvlForm,{
    req(input$DomaineNvlFormation, input$AjoutNvlForm)
    
    TabFormat <- TabFormation()
    FormTemp <-  c(input$DomaineNvlFormation,input$AjoutNvlForm,1)
    TabFormat <- rbind(TabFormat,FormTemp)
    TabFormat <- distinct(TabFormat)
    
    return(TabFormat)
  })
  
  # --------------------------------------------------------------------------------------------------------------
  observeEvent(donnees_Ajout_Formations(),{
    temp <- donnees_Ajout_Formations()
    saveRDS(temp,paste0(Chemin,"Donnees/Travail/TabFormations.rds"))
    
  })
  
  donnees_Ajout_NvxChoix <- eventReactive(input$ValidAjoutNvlForm,{
    req(input$ChoixAgent, input$AjoutNvlForm)
    
    AjoutNvxChoix <- donnees_Forma_Autre_Choix()[,-c(12)]
    BaseTemp <-  AjoutNvxChoix[AjoutNvxChoix$IdAgent %in% input$ChoixAgent,]
    
    BaseTemp[,c("Formation","Desiderata")] <- c(input$AjoutNvlForm,"Oui")
    AjoutNvxChoix <- rbind(mes_donnees(),BaseTemp)
    AjoutNvxChoix <- distinct(AjoutNvxChoix)
    
    return(AjoutNvxChoix)
  })
  
  # --------------------------------------------------------------------------------------------------------------
  observeEvent(donnees_Ajout_NvxChoix(),{
    tempNvxChx <- donnees_Ajout_NvxChoix() #AjoutNvxChoix 
    
    saveRDS(tempNvxChx,paste0(Chemin,"Donnees/Travail/ListFormation_By_Id.rds"))
  })
  
  
  # --------------------------------------------------------------------------------------------------------------
  
  donnees_Etat_AutreChoix <- eventReactive(input$ValidEtatChpLib,{
    req(input$ChoixAgent)
    
    EtatChxLib <- donnees_Forma_Autre_Choix()
    EtatChxLib[EtatChxLib$IdAgent == input$ChoixAgent,"Etat"] <-  "Champ libre traité"
    
    return(EtatChxLib)
    
  })
  
  observeEvent(donnees_Etat_AutreChoix(),{
    tempEtat <- donnees_Etat_AutreChoix()
    saveRDS(tempEtat,paste0(Chemin,"Donnees/Travail/ListAutChx.rds"))
  })
  
  observeEvent(input$ValidQuitter,{
    stopApp()
  })
  
  observe({
    if(input$ValidChxRepert==2){
      stopApp()
    }
  })
  
  donnees_Tableau_Formations <- reactive({
    donnees_Forma_Demande <-  mes_donnees()[,c(8:10)]
    # Entrée par Formations : liste des agents pour chacune des formations
    ListForm <-  donnees_Forma_Demande[order(donnees_Forma_Demande$Formation, donnees_Forma_Demande$IdAgent),]
    ListForm$NumLigne <- c(1:nrow(ListForm))
    
    ListForm<- ddply(ListForm,.(Formation),transform,rng=rank(rank(NumLigne)))
    
    # ici _______________________________________________________________________________________________________________
    ListForm <- ListForm %>% 
      mutate(rng = case_when(ListForm$rng >=0 & ListForm$rng <=9  ~ paste0("0",ListForm$rng),
                             ListForm$rng >=10 ~ as.character(ListForm$rng)))
    # ici _______________________________________________________________________________________________________________
    
    
    ListForm$RgAgent <- paste0("Agent",ListForm$rng)
    
    ListForm <- ListForm[,c("Formation","IdAgent","RgAgent")]
    
  })  
  
  # _______________________________________________________________________________________________________________
  
  donnees_Tableau_Agents <- reactive({
    
    ListAgents <- mes_donnees()[order(mes_donnees()$IdAgent,mes_donnees()$Formation),]
    ListAgents$NumLigne <- c(1:nrow(ListAgents))
    ListAgents<- ddply(ListAgents,.(IdAgent),transform,rng=rank(rank(NumLigne)))
    
    # ici _______________________________________________________________________________________________________________
    ListAgents <- ListAgents %>% 
      mutate(rng = case_when(ListAgents$rng >=0 & ListAgents$rng <=9  ~ paste0("0",ListAgents$rng),
                             ListAgents$rng >=10 ~ as.character(ListAgents$rng)))
    # ici _______________________________________________________________________________________________________________
    
    ListAgents$RgForm <- paste0("Formation",ListAgents$rng)
    names(ListAgents)
    ListAgents <- ListAgents[,c("Nom","IdAgent","Formation","RgForm")]
    
  })  
  
  
  donnees_FicheIndiv <- reactive({
    FI <- donnees_Tableau_Agents()%>%
      filter(IdAgent %in% input$ChoixIdAgent)%>%
      select(Nom,Formation)
  })
  
  donnees_GenererFI <- observeEvent(input$Valid_GenererFI,{
    FI <- mes_donnees()
    FI <- FI[order(FI$IdAgentBySupH),]
    ListFI <- unique(FI$IdAgent)
    ListFISupH <- unique(FI$IdAgentBySupH)
    
    wb<-createWorkbook(type="xlsx")
    # loadWorkbook("C:/Temp/myFile.xls")
    
    # ______________________________
    # Definir quelques styles
    #______________________________
    # Titre et sous-titre
    TITLE_STYLE <- CellStyle(wb)+ Font(wb,  heightInPoints=16, 
                                       color="blue", isBold=TRUE, underline=1)
    SUB_TITLE_STYLE <- CellStyle(wb) + 
      Font(wb, heightInPoints=14,
           isItalic=TRUE, isBold=FALSE)
    
    # Styles pour le nom des lignes/colonnes
    TABLE_ROWNAMES_STYLE <- CellStyle(wb) + Font(wb, isBold=TRUE)
    TABLE_COLNAMES_STYLE <- CellStyle(wb) + Font(wb, isBold=TRUE) +
      Alignment(wrapText=TRUE, horizontal="ALIGN_CENTER") +
      Border(color="black", position=c("TOP", "BOTTOM"), 
             pen=c("BORDER_THIN", "BORDER_THICK")) 
    
    
    xlsx.addTitle <- function (sheet, rowIndex, title, titleStyle){
      rows <-createRow(sheet,rowIndex=rowIndex)
      sheetTitle <-createCell(rows, colIndex=1)
      setCellValue(sheetTitle[[1,1]], title)
      setCellStyle(sheetTitle[[1,1]], titleStyle)
    }
    
    
    for (i in 1:length(ListFI)){
      GenerFI <- FI %>%
        filter(IdAgent == ListFI[i])
      ListFISupH <- unique(GenerFI$IdAgentBySupH)
      names(GenerFI)[c(1:2,5,8)]<- c("Nom agent","Prénom agent","Formations demandées","Service N+1 & Identif")
      Nom <- unique(GenerFI$`Nom agent`)
      Prenom <- unique(GenerFI$`Prénom agent`)
      Service <- unique(GenerFI$`Service Agent`)
      Groupe <- unique(GenerFI$`Groupe Agent`)
      
      Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")
      render(input = paste0(CheminPgm,"Rmd_FichesIndiv.Rmd"),
             output_format = input$FormatFI,
             output_dir = paste0(Chemin,"Donnees/OutPuts/Fiches individuelles de formation"),
             if(input$FormatFI == "word_document"){
               output_file = paste0(ListFISupH,".doc")
             }else if(input$FormatFI == "html_document"){
               output_file = paste0(ListFISupH,".html")
             }
             ,encoding = "UTF-8",
             run_pandoc = T)
    }
    return(ListFI)
    
  })
  
  # _______________________________________________________________________________________________________________
  # _______________________________________________________________________________________________________________
  
  
  # liste de choix des identifiants d'agents : pour les fiches individuelles de formation
  output$affichage_choix_Id_Agent <- renderUI({
    listeIdAgent <- sort(unique(mes_donnees()$IdAgent))
    
    selectInput("ChoixIdAgent",
                h3("Visualiser la fiche individuelle de formation de :"),
                choices = listeIdAgent,
                multiple = F)
  })
  
  
  output$affichage_choix_Agent <- renderUI({
    TablisteAgents <- donnees_Forma_Autre_Choix()[,c("IdAgent","Etat")]
    
    if(input$FiltAgentAjtForm == 1){
      listeAgents <- sort(unique(TablisteAgents$IdAgent))
    }else if (input$FiltAgentAjtForm == 2){
      listeAgents <- sort(unique(TablisteAgents[TablisteAgents$Etat == "A traiter",1]))
      
    }
    selectInput("ChoixAgent",
                h3("Sélectionner un agent"),
                choices = listeAgents,
                multiple = F)
  })
  
  # --------------------------------------------------------------------------------------------------------------
  output$affichage_Domaine_Formation <- renderUI({
    ListeDomaines <- sort(unique(TabFormation()[,1]))
    
    selectInput("DomaineFormation",
                "Domaine de la formation recherchée",
                choices = ListeDomaines,
                multiple = F)
    
  })
  
  output$affichage_Domaine_NvlForm <- renderUI({
    ListeDomaines <- sort(unique(TabFormation()[,1]))
    
    selectInput("DomaineNvlFormation",
                "A quel domaine souhaitez-vous ajouter votre nouvelle formation ?",
                choices = ListeDomaines,
                multiple = F)
  })
  
  # --------------------------------------------------------------------------------------------------------------
  output$affichage_choix_Formation2 <- renderUI({
    listeFormation <- TabFormation()
    listeFormation <- listeFormation[listeFormation$DOMAINES %in% input$DomaineFormation,]
    listeFormation <- sort(unique(listeFormation$FORMATIONS))
    
    selectInput("ChoixFormation2",
                "Liste des formations",
                choices = listeFormation,
                multiple = F)
  })
  # _______________________________________________________________________________________________________________
  # _______________________________________________________________________________________________________________
  # _______________________________________________________________________________________________________________
  
  output$NbVarSortieLs <- renderText({
    paste0("Votre tableau (Sortie_LS) contient désormais ",length(Traitement_Sortie_LS())," colonnes")
  })
  
  output$NomVarSortieLs <- renderPrint({
    Traitement_Sortie_LS()
  })
  
  
  Donnees_AffichTabForm <- reactive({
    ListForm <- TabFormation()
    ListForm
  })
  
  output$ListForm <- DT::renderDataTable({
    req(input$VisuTabForm)
    ListForm <- Donnees_AffichTabForm()
    ListForm <- ListForm[order(ListForm[,1]),c(1:2)]
    
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      ListForm,
      rownames = T,
      extensions = c('KeyTable','FixedHeader'),
      options = list(dom = 'Bfrtip',
                     # extensions : KeyTable (cliquer sur une cellule)
                     keys = TRUE,
                     
                     # extensions : FixedHeader
                     pageLength = 10,
                     fixedHeader = F
                     ,
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'Black', 'color': 'SkyBlue'});","}"))) %>%
      formatStyle(1:ncol(ListForm),color='Black', backgroundColor = 'LightYellow')                
  })
    
  # output$ListForm2 <- DT::renderDataTable({
  #   req(input$VisuTabForm2)
  #   ListForm <- Donnees_AffichTabForm()
  #   ListForm <- ListForm[order(ListForm[,1]),c(1:2)]
  #   
  #   
  #   # ---------------------------------------------------------------------------------------------------------------
  #   # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
  #   datatable(
  #     ListForm,
  #     rownames = T,
  #     extensions = c('KeyTable','FixedHeader'),
  #     options = list(dom = 'Bfrtip',
  #                    # extensions : KeyTable (cliquer sur une cellule)
  #                    keys = TRUE,
  #                    
  #                    # extensions : FixedHeader
  #                    pageLength = 10,
  #                    fixedHeader = F
  #                    ,
  #                    # # Formattage de la ligne d'en-tête (couleurs)
  #                    initComplete = JS("function(settings, json) {",
  #                                      "$(this.api().table().header()).css({'background-color': 'Black', 'color': 'SkyBlue'});","}"))) %>%
  #     formatStyle(1:ncol(ListForm),color='Black', backgroundColor = 'NavajoWhite')
  # })
  
  
  output$TabChargement <- DT::renderDataTable({
    Tab <- mes_donnees()[, c(1,2,8,4,5,6,7,10)]
    names(Tab) <- c("Nom","Prénom","Formations demandées","Service de l'agent","Groupe de l'agent","Service du N+1","Groupe du N+1","Identifiant de l'agent")
    Tab
    
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      Tab,
      rownames = T,
      extensions = c('ColReorder','KeyTable','FixedHeader','Buttons'),
      options = list(dom = 'Bfrtip',
                     # extensions : ColReorder (bouger les colonnes)
                     colReorder = TRUE,
                     # extensions : KeyTable (cliquer sur une cellule)
                     keys = TRUE,
                     
                     # extensions : FixedHeader
                     pageLength = 50,
                     fixedHeader = F,
                     
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"),
                     
                     
                     # extensions : Buttons (colonnes à afficher ou 'désafficher')
                     buttons = list('copy', 'print',
                                    list(extend = 'collection',
                                         buttons = c('csv','excel', 'pdf'),
                                         text = 'Charger le tableau de données ...'),
                                    list(extend = 'colvis',
                                         columns = 4:ncol(Tab),text='Masquer colonnes')))) %>%
      
      # buttons = list(list(extend = 'colvis', columns = c(2:4,6),text='Masquer colonnes')))) %>%
      formatStyle(1:ncol(Tab),color='Black', backgroundColor = NULL)                
  })
    

  
  output$ModifForm <- DT::renderDataTable({
    ModifForm <- donnees_Forma_Autre_Choix()[donnees_Forma_Autre_Choix()$IdAgent %in% input$ChoixAgent,
                                c("Nom","Prenom","IdAgent","Desiderata","Etat")]
    ModifForm
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      ModifForm,
      rownames = T,
      extensions = c('KeyTable'),
      options = list(dom = 'Bfrtip',
                     keys = TRUE,
                  
                      # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"))) %>%
      formatStyle(1:ncol(ModifForm),color='Black', backgroundColor = NULL)
    
  })
  
  output$verif <- DT::renderDataTable({
    AfficheChoixAgent <-  mes_donnees() 
    AfficheChoixAgent <- AfficheChoixAgent[AfficheChoixAgent$IdAgent %in% input$ChoixAgent,c(1:2,10,8)]
    AfficheChoixAgent
    
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      AfficheChoixAgent,
      rownames = T,
      extensions = c('KeyTable'),
      options = list(dom = 'Bfrtip',
                     keys = TRUE,
                     
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"))) %>%
      formatStyle(1:ncol(AfficheChoixAgent),color='Black', backgroundColor = NULL)
    
    
  })
  
  output$AffichageTableFormations <- DT::renderDataTable({
    TabForm <- spread(donnees_Tableau_Formations(),RgAgent,IdAgent,fill=" ")
    file.remove("Donnees/OutPuts/TabForm.xlsx")
    write.xlsx(TabForm,paste0(Chemin,"Donnees/Outputs/TabForm.xlsx"))
    TabForm
    
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      TabForm,
      rownames = T,
      extensions = c('ColReorder','KeyTable','FixedHeader','Buttons'),
      options = list(dom = 'Bfrtip',
                     # extensions : ColReorder (bouger les colonnes)
                     colReorder = TRUE,
                     # extensions : KeyTable (cliquer sur une cellule)
                     keys = TRUE,
                     
                     # extensions : FixedHeader
                     pageLength = 50,
                     fixedHeader = F,
                     
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"),
                     
                     
                     # extensions : Buttons (colonnes à afficher ou 'désafficher')
                     buttons = list('copy', 'print',
                                    list(extend = 'collection',
                                         buttons = c('csv','excel', 'pdf'),
                                         text = 'Charger le tableau de données ...')))) %>%
      formatStyle(1:ncol(TabForm),color='Black', backgroundColor = NULL)            
    
  })
  
  
  output$AffichageListeFormations <- DT::renderDataTable({
    TabFormations <- TabFormation()
    TabFormations <- TabFormations[order(TabFormations$DOMAINES,TabFormations$FORMATIONS),c(1:2)]
  })
  
  output$NbFormations <- renderText({
    paste0(nrow(TabFormation())," formations répertoriées")
  })
  
  
  output$VisuTabModif <- DT::renderDataTable({
    VisuAutChx <- donnees_Forma_Autre_Choix()
    VisuAutChx <- VisuAutChx[VisuAutChx$Etat %in% input$TypeFiltre,
                             c("Nom","Prenom","Etat","IdAgent")]
    names(VisuAutChx) <- c("Nom","Prénom","Etat","Identifiant de l'agent")
    VisuAutChx
    
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      VisuAutChx,
      rownames = T,
      extensions = c('ColReorder','KeyTable','FixedHeader','Buttons'),
      options = list(dom = 'Bfrtip',
                     # extensions : ColReorder (bouger les colonnes)
                     colReorder = TRUE,
                     # extensions : KeyTable (cliquer sur une cellule)
                     keys = TRUE,
                     
                     # extensions : FixedHeader
                     pageLength = 50,
                     fixedHeader = F,
                     
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"),
                     
                     
                     # extensions : Buttons (colonnes à afficher ou 'désafficher')
                     buttons = list('copy', 'print',
                                    list(extend = 'collection',
                                         buttons = c('csv','excel', 'pdf'),
                                         text = 'Charger le tableau de données ...'),
                                    list(extend = 'colvis',
                                         columns = 4,text='Masquer colonnes')))) %>%
      
      # buttons = list(list(extend = 'colvis', columns = c(2:4,6),text='Masquer colonnes')))) %>%
      formatStyle(1:ncol(VisuAutChx),color='Black', backgroundColor = NULL)
    
  })
  
  
  output$AffichageTableAgents <- DT::renderDataTable({
    TabAgents <- spread(donnees_Tableau_Agents(),RgForm,Formation,fill=" ")
    file.remove("Donnees/OutPuts/TabAgents.xlsx")
    
    write.xlsx(TabAgents,paste0(Chemin,"Donnees/Outputs/TabAgents.xlsx"))
    TabAgents
    
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      TabAgents,
      rownames = T,
      extensions = c('ColReorder','KeyTable','FixedHeader','Buttons'),
      options = list(dom = 'Bfrtip',
                     # extensions : ColReorder (bouger les colonnes)
                     colReorder = TRUE,
                     # extensions : KeyTable (cliquer sur une cellule)
                     keys = TRUE,
                     
                     # extensions : FixedHeader
                     pageLength = 50,
                     fixedHeader = F,
                     
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"),
                     
                     
                     # extensions : Buttons (colonnes à afficher ou 'désafficher')
                     buttons = list('copy', 'print',
                                    list(extend = 'collection',
                                         buttons = c('csv','excel', 'pdf'),
                                         text = 'Charger le tableau de données ...')))) %>%
      formatStyle(1:ncol(TabAgents),color='Black', backgroundColor = NULL)            
  
  })
  
  
  output$ChargementFI <- DT::renderDataTable({
    VisuFI <- donnees_FicheIndiv()
    
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      VisuFI,
      rownames = T,
      extensions = c('KeyTable','Buttons','FixedHeader'),
      options = list(dom = 'Bfrtip',
                     # extensions : KeyTable (cliquer sur une cellule)
                     keys = TRUE,
                     # extensions : FixedHeader
                     pageLength = 30,
                     fixedHeader = F,
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"),
                     
                     
                     # extensions : Buttons (colonnes à afficher ou 'désafficher')
                     buttons = list('copy', 'print',
                                    list(extend = 'collection',
                                         buttons = c('csv','excel', 'pdf'),
                                         text = 'Exporter la fiche ...')))) %>%
      
      # buttons = list(list(extend = 'colvis', columns = c(2:4,6),text='Masquer colonnes')))) %>%
      formatStyle(1:ncol(VisuFI),color='Black', backgroundColor = NULL)
    
    
    
  })
  
  output$GenerFI <- renderText({
    if(input$Valid_GenererFI){
      progress <- Progress$new(min=1, max=15)
      on.exit(progress$close())
      
      progress$set(message = 'Création des fiches indivuelles de formations ...',
                   detail = '... en cours')
      
      for (i in 1:15) {
        progress$set(value = i)
        Sys.sleep(0.1)
      }
      
      ListFI <- unique(mes_donnees()$IdAgent)
      
      paste0("Vous venez de générer ",length(ListFI)," fiches individuelles de formation")
    }
    
    
  })
  
  output$Stats0 <- renderTable({
    Stats0 <- n_distinct(mes_donnees()$IdAgent)
    paste0(Stats0," agents demandant au moins 1 formation")
    
  })
  output$Stats1 <- renderTable({
    Stats1 <- table(mes_donnees()$Formation)
    Stats1 <-as.data.frame(Stats1)
    names(Stats1) <- c("Nom de la formation", "Effectifs")
    Stats1 <- Stats1[order(-Stats1$Effectifs),]
    Stats1
    
    
  })
  
  output$Stats2 <- renderTable({
    Stats2 <- table(mes_donnees()$IdAgent)
    Stats2 <-as.data.frame(Stats2)
    names(Stats2) <- c("Identifiant de l'agent", "Effectifs")
    Stats2 <- Stats2[order(-Stats2$Effectifs),]
    Stats2
  })
  
  output$Stats3 <- renderTable({
    Stats3 <- table(mes_donnees()$`Service Agent`)
    Stats3 <-as.data.frame(Stats3)
    names(Stats3) <- c("Nom du Service", "Effectifs")
    Stats3 <- Stats3[order(-Stats3$Effectifs),]
    Stats3
  })
  
  output$Stats5 <- renderTable({
    Stats5 <- table(mes_donnees()$`Service Agent`,mes_donnees()$`Groupe Agent`)
    Stats5 <-as.data.frame(Stats5)
    names(Stats5) <- c("Nom du Service","Nom du Groupe", "Effectifs")
    Stats5 <- Stats5[order(Stats5$`Nom du Service`,Stats5$`Nom du Groupe`,-Stats5$Effectifs),]
    Stats5
  })
  
  output$Stats4 <- renderTable({
    Stats4 <- table(donnees_Forma_Autre_Choix()$Etat)
    Stats4 <-as.data.frame(Stats4)
    names(Stats4) <- c("Etat du champ libre", "Effectifs")
    Stats4 <- Stats4[order(-Stats4$Effectifs),]
    Stats4
  })
  
  
  output$VerifUtilisateur <- renderPrint({
    MaxCharUtilisateur <- nchar(Chemin)
    NomUtilisateur <- substr(Chemin,29,MaxCharUtilisateur-1)
    cat(paste0("unité sélectionnée : ",NomUtilisateur))
  })
    
  output$VerifNomAgents <- DT::renderDataTable({
    BaseAgents <- read_ods(paste0(Chemin,"Donnees/Inputs/BaseAgents.ods"),
                           sheet = 1,
                           col_names = T)
    VerifListAgts <- BaseAgents[,1:2]
    names(VerifListAgts) <- c("Nom","Prénom")
    VerifListAgts <- VerifListAgts[order(VerifListAgts$Nom,VerifListAgts$Prénom),]
    # VerifListAgts <- head(VerifListAgts,10)
    VerifListAgts
    # ---------------------------------------------------------------------------------------------------------------
    # Création de fonctions spécifiques au tableau : boutons affichage et 'désaffichage' de colonnes + Réorganisation des colonnes + Sélection de cellules
    datatable(
      VerifListAgts,
      rownames = T,
      extensions = c('KeyTable'),
      options = list(dom = 'Bfrtip',
                     keys = TRUE,
                     
                     # # Formattage de la ligne d'en-tête (couleurs)
                     initComplete = JS("function(settings, json) {",
                                       "$(this.api().table().header()).css({'background-color': 'SkyBlue', 'color': 'Black'});","}"))) %>%
      formatStyle(1:ncol(VerifListAgts),color='Black', backgroundColor = NULL)
    
    
  })
    
})
  
  
  