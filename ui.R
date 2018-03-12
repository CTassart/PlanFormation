# _______________________________________________________________________________________________________________
# Dernière mise à jour : 02-02-2018 - 16h00
# _______________________________________________________________________________________________________________

CheminTravail <- "D:/T19QHL/Mes Documents/Appli R/Planpreform/"
CheminPkg <- paste0(CheminTravail,"packrat/lib/x86_64-w64-mingw32/3.4.2/")
bibliotheque <- paste0(CheminTravail,"packrat/lib/x86_64-w64-mingw32/3.4.2") #chemin complet vers mon dossier de packages
.libPaths(bibliotheque) #on fixe une variable d'environnement : en gros, il va chercher par défaut les packages dans le chemin bibliotheque
#require(htmltools, lib.loc = CheminPkg)
library(shinythemes, warn.conflicts = FALSE, quietly = TRUE, verbose = FALSE)

# ---------------------------------------------------------------------------------------------------------------

shinyUI(navbarPage (theme=shinytheme("cerulean"),"PLAN DE FORMATION - V2 - EN COURS DE DEVELOPPEMENT",
                    tabPanel("ACCUEIL",
                             sidebarPanel(width=8,
                                          h1("Pré-plan de formation"),
                                          radioButtons("ValidChxRepert",
                                                       h3("Assurez-vous d'avoir sélectionné le répertoire de votre unité"),
                                                       c("je continue"=1,
                                                         "Je quitte l'application"=2),
                                                       selected = 1),
                                          br(),tags$hr(),
                                          
                                          h2("- Lors de la première utilisation, veuillez lire les instructions"),
                                          h4("Rendez-vous sur le panneau 'CONSEILS D'UTILISATION'"),
                                          tags$hr(),tags$hr(),
                                          
                                          
                                          actionButton("ValidQuitter","J'ai terminé ! Je désactive l'application",icon = icon("window-close")),
                                          tags$hr()
                                          
                             ),
                             mainPanel(width=4,
                                       textOutput("VerifUtilisateur"),
                                       tags$hr(),tags$hr(),
                                       
                                       h3("Liste des agents de l'unité :"),
                                       DT::dataTableOutput("VerifNomAgents")
                             )
                    ),
                    tabPanel("AJOUTER DES FORMATIONS",
                             sidebarLayout(
                               sidebarPanel(width=3,   
                                            h1("Pré-plan de formation"),
                                            tags$hr(),
                                        
                                            uiOutput("affichage_choix_Agent"),
                                            radioButtons(inputId = "FiltAgentAjtForm",
                                                         label=(" "),
                                                         c("Ensemble des agents"=1, "Agents ayant des demandes spécifiques non traitées"=2),
                                                         selected = 2 ),
                                            tags$hr(),
                                            h3("Répertoire des formations"),
                                            checkboxInput("VisuTabForm","Afficher"),
                                            p("------------------------------------------------------"),
                                            radioButtons("AjoutForms",
                                                         h3("Actualiser son plan de formation "),
                                                         choices=c("Afficher les demandes"=0,
                                                                   "Ajouter une formation existante"=1,
                                                                   "Ajouter une autre formation"=2),
                                                         selected=0),
                                            
                                            conditionalPanel(
                                              condition = "input.AjoutForms == '1'",
                                              # tags$hr(),br(),
                                              h3("Formations existantes :"),
                                              p("Choisir le domaine puis la formation de ce domaine"),
                                              h3("Choix du domaine"),
                                              uiOutput("affichage_Domaine_Formation"),
                                              uiOutput("affichage_choix_Formation2"),
                                              tags$hr(),br(),
                                              
                                              # checkboxInput("VisuTabForm","Visualisez la liste des formations répertoriées"),
                                              actionButton("validModif", "Ajouter la formation",icon = icon("thumbs-up")),
                                              tags$hr(),br()
                                              
                                            ),
                                            conditionalPanel(
                                              condition="input.AjoutForms == '2'",
                                              h3("Nouvelle formation :"),
                                              p("Choisir un domaine puis la formation à ajouter à ce domaine"),
                                              h3("Choix du domaine"),
                                              uiOutput("affichage_Domaine_NvlForm"),
                                              textInput("AjoutNvlForm","Ecrivez le nom de la nouvelle formation"),
                                              tags$hr(),br(),
                                              
                                              # checkboxInput("VisuTabForm2","Visualisez la liste des formations répertoriées"),
                                              actionButton("ValidAjoutNvlForm","Ajouter la formation",icon = icon("thumbs-up")),
                                              p("la formation est ajoutée à l'agent ET à la liste des formations"),
                                              tags$hr(),br()
                                              
                                            ),
                                            p("------------------------------------------------------"),
                                            h3("Etat des demandes :"),
                                            actionButton("ValidEtatChpLib","Considérer que le champ libre a été 'Traité'",icon = icon("thumbs-up")),
                                            p("Cliquer ici lorsque vous avez traité le champ libre de l'agent sélectionné")
                                            
                               ),
                               
                               mainPanel(
                                 textOutput("NbFormations"),
                                 tags$hr(), br(),
                                 
                                 h1("Visualisation des demandes"),
                                 p("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"),
                                 h3("Les formations demandées par l'agent"),
                                 p("(hors champ libre)"),
                                 DT::dataTableOutput("verif"),
                                 tags$hr(),br(),
                                 
                                 p("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"),
                                 
                                 h3("Les demandes spécifiques (champs libres)"),
                                 DT::dataTableOutput("ModifForm"),
                                 tags$hr(),br(),
                                 
                                 p("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------"),
                                 DT::dataTableOutput("ListForm")
                                 # ,DT::dataTableOutput("ListForm2")
                                 
                                 # ,
                                 
                                 # p("------------------------------------------------------"),
                                 # # h1("Visualisation de la table des formations"),
                                 # DT::dataTableOutput("ListForm"),
                                 # DT::dataTableOutput("ListForm2")
                                 
                               )
                             )
                    ),
                    
                    navbarMenu("PLANS DE FORMATION ...",
                               tabPanel("- Par formation",
                                        mainPanel(
                                          h1("Liste des",strong("agents")," par formation"),
                                          h4("(Enregistrement automatique sous : Donnees/OutPuts/TabForm.xlsx)"),
                                          
                                          tags$hr(),br(),
                                          DT::dataTableOutput("AffichageTableFormations"),
                                          tags$hr(),br()
                                        )
                               ),
                               
                               tabPanel("- Par agent",
                                        mainPanel(
                                          h1("Liste des",strong("formations")," par agent"),
                                          h4("(Enregistrement automatique sous : Donnees/OutPuts/TabAgents.xlsx)"),
                                          
                                          tags$hr(),br(),
                                          DT::dataTableOutput("AffichageTableAgents"),
                                          tags$hr(),br()
                                        )
                               )
                    ),
                    tabPanel("FICHES INDIVIDUELLES",
                             sidebarLayout(
                               sidebarPanel(width=12,   
                                            radioButtons(inputId="VisuOuGenerFI",
                                                         label=h3("Choix"),
                                                         choices=c("Visualiser la fiche d'un agent"=1,
                                                                   "Générer toutes les fiches individuelles de formation"=2),
                                                         inline = T),
                                            br(),
                                            conditionalPanel(
                                              condition="input.VisuOuGenerFI==1",
                                              # h3("Sélectionnez l'agent pour lequel vous souhaitez visualiser la fiche individuelle de formation"),
                                              uiOutput("affichage_choix_Id_Agent"),
                                              p("ne concerne que les agents ayant sollicité au moins 1 formation")
                                            ),
                                            conditionalPanel(
                                              condition="input.VisuOuGenerFI==2",
                                              h3("Générer les fiches individuelles pour tous les agents"),
                                              radioButtons("FormatFI",
                                                           "Dans quel format souhaitez-vous générer les fiches individuelles de formation ?",
                                                           c("Word"="word_document","HTML"="html_document"),
                                                           selected ="word_document",
                                                           inline = T),
                                              actionButton("Valid_GenererFI", "Générer les fiches individuelles", icon = icon("thumbs-up")),
                                              p("Ne cliquer qu'une fois puis attendre le message annonçant le nombre de fiches individuelles générées"),
                                              br()
                                            )
                               ),
                               mainPanel(
                                 # h1("Fiches individuelles"),
                                 conditionalPanel(
                                   condition="input.VisuOuGenerFI == 1",
                                   DT::dataTableOutput("ChargementFI")
                                 ),
                                 conditionalPanel(
                                   condition="input.VisuOuGenerFI == 2",
                                   
                                   h3("Fiches générées"),
                                   textOutput("GenerFI"),
                                   br()
                                   # ,p("'Répertoire de votre unité'/Donnees/OutPuts/Fiches individuelles.xlsx")
                                   ,p("'Répertoire de votre unité'/Donnees/OutPuts/Fiches individuelles de formation/..."),
                                   p("Nom des fiches : Service du N+1 - Groupe du N+1 - Nom et Prénom de l'agent")
                                 )
                                 
                               )
                             )
                    ),
                    navbarMenu("VISUALISATION DES DONNEES",
                               tabPanel("- Ensemble des formations demandées",
                                        # sidebarLayout(
                                          # sidebarPanel(width=12,
                                          #              h1("Pré-plan de formation"),
                                          #              tags$hr(),
                                          #              h3("Modifier l'ordre de tri"),
                                          #              radioButtons("OrdreTri",
                                          #                           "------------------------------------------------------",
                                          #                           c("Par nom (1)"="Nom",
                                          #                             "Par formation (3)"="Formation",
                                          #                             "Par service Agent (5)"="Service Agent"),
                                          #                           inline = T),
                                          #              p("------------------------------------------------------")
                                          # ),
                                          mainPanel(width=12,
                                                    h1("Liste des formations demandées, par agent"),
                                                    p("(ne comprend pas les demandes spécifiques (champs libres))"),
                                                    tags$hr(),br(),

                                                    DT::dataTableOutput("TabChargement")
                                          )
                                        # )
                               ),

                               tabPanel("- Etat des champs libres",
                                        sidebarLayout(
                                          sidebarPanel(width=12,
                                                       h1("Pré-plan de formation"),
                                                       checkboxGroupInput(inputId = "TypeFiltre",
                                                                          label = h3("Restreindre la liste aux champs libres ... "),
                                                                          choices = c("à traiter"="A traiter",
                                                                                      "traités"="Champ libre traité",
                                                                                      "non renseignés"="Non renseigné"),
                                                                          inline = T,
                                                                          selected = c("A traiter","Champ libre traité"))
                                          ),
                                          mainPanel(width=12,
                                                    h1("Liste des demandes spécifiques"),
                                                    p("(selon l'état de traitement des champs libres"),
                                                    DT::dataTableOutput("VisuTabModif")
                                          )
                                        )
                               )
                    ),
                    tabPanel("STATISTIQUES",
                             sidebarLayout(
                               sidebarPanel(width=3,     
                                            br(),
                                            h3("Afficher des statistiques simples"),
                                            radioButtons(inputId="AfficherStats",
                                                         label="quelles statistiques souhaitez-vous afficher ?",
                                                         choices= c("Nombre d'agents demandant au moins une formation"="Stats0",
                                                                    "Nombre de candidats, par formation"="Stats1",
                                                                    "Nombre de formations demandées, par agent"="Stats2",
                                                                    "Nombre de formations demandées, par service"="Stats3",
                                                                    "Nombre de formations demandées, par groupe"="Stats5",
                                                                    "Répartition des demandes spécifiques, selon l'état"="Stats4"),
                                                         selected = "Stats0")
                               ),
                               mainPanel(
                                 conditionalPanel(
                                   condition="input.AfficherStats == 'Stats0'",
                                   h3("Nombre d'agents demandant au moins une formation"),
                                   tableOutput("Stats0"),
                                   tags$hr(), br()
                                 ),
                                 
                                 conditionalPanel(
                                   condition="input.AfficherStats == 'Stats1'",
                                   h3("Nombre de candidats, par formation"),
                                   tableOutput("Stats1"),
                                   tags$hr(), br()
                                 ),
                                 
                                 
                                 conditionalPanel(
                                   condition="input.AfficherStats == 'Stats2'",
                                   h3("Nombre de formations demandées, par agent"),
                                   tableOutput("Stats2"),
                                   tags$hr(), br()
                                 ),
                                 
                                 conditionalPanel(
                                   condition="input.AfficherStats == 'Stats3'",
                                   h3("Nombre de formations demandées, par service"),
                                   tableOutput("Stats3"),
                                   tags$hr(), br()
                                 ),
                                 conditionalPanel(
                                   condition="input.AfficherStats == 'Stats5'",
                                   h3("Nombre de formations demandées, par groupe"),
                                   tableOutput("Stats5"),
                                   tags$hr(), br()
                                 ),
                                 
                                 conditionalPanel(
                                   condition="input.AfficherStats == 'Stats4'",
                                   h3("Répartition des demandes spécifiques, selon l'état"),
                                   tableOutput("Stats4"),
                                   tags$hr(), br()
                                 )
                                 
                               )
                             )
                    ),
                    tabPanel("CONSEILS D'UTILISATION",
                             mainPanel(
                               h1("Pré-plan de formation"),
                               h3(".  Conseils d'utilisation de l'application"),
                               tags$hr(),tags$hr(),
                               
                               # --------------------------------------------------------------------------------------------------------------
                               h3("TRAVAIL PREALABLE"),
                               p("Copiez les 3 fichiers, nécessaires au bon fonctionnement de l'application, dans Donnees/Inputs (de votre unité)"),
                               
                               p("- BaseAgents.ods    : liste des agents et de leur affectation"),
                               p("- TabFormations.ods	: liste des formations"),
                               p("- TabSorties_LS.ods	: sorties (résultats) du questionnaire Lime Survey"),
                               
                               h4("Lors de la 1ère utilisation, vous aurez besoin de paramétrer l'application et formater vos données : Cf '... PARAMETRAGE INITIAL... ' "),
                               tags$hr()
                               
                             
                               
                               # # --------------------------------------------------------------------------------------------------------------
                               # ,h3("VISUALISATION DONNEES"),
                               # p("Panneau permettant de visualiser le tableau récapitulatif des formations demandées par les agents.
                               #   C'est à dire : "),
                               # p("- Les formations pour lesquelles l'agent a répondu 'Oui'"),
                               # p("3 boutons permettent de trier les données par le nom (colonne 1), par l'intitulé de la formation (colonne 3) ou le service de l'agent (colonne 5)"),
                               # tags$hr(),tags$hr(),
                               # 
                               # # --------------------------------------------------------------------------------------------------------------
                               # h3("TRAITEMENT DES DEMANDES PARTICULIERES ..."),
                               # # --------------------------------
                               # h4("- Ajout d'une formation à un agent "),
                               # p("Le panneau principal permet de visualiser 2 tableaux :"),
                               # h5("___ 1er tableau (haut) : "),
                               # p(" permet de voir si l'agent a demandé une formation qui ne se trouvait pas
                               #   dans la liste des formations proposées."),
                               # h5("___ 2ème tableau (bas) : "),
                               # p(" affiche l'ensemble des formations demandées par l'agent."),
                               # p(" Celui-ci s'actualise au fur et à mesure des ajouts de formation."),
                               # tags$hr(),
                               # 
                               # h4("Le panneau de sélection permet d'ajouter une ou plusieurs formations à un agent. Pour cela : "),
                               # p("- sélectionner préalablement l'agent à qui l'on souhaite ajouter une formation."),
                               # br(),
                               # h5("La formation est déjà répertoriée dans la liste des formations :"),
                               # p("Les formations sont proposées par le biais d'de 2 listes déroulantes :"),
                               # p("- tout d'abord, choisir le domaine de la formation,"),
                               # p("- puis choisir la formation que l'on souhaite ajouter à l'agent."),
                               # p(" Valider en cliquant sur 'Ajouter la formation'"),
                               # br(),
                               # 
                               # h5("La formation n'est pas répertoriée :"),
                               # p("- tout d'abord, choisir le domaine de la formation,"),
                               # p("- puis saisir le nom de la nouvelle formation."),
                               # p(" Valider en cliquant sur 'Ajouter la formation'"),
                               # p("Cette formation s'ajoute à l'agent en cours de sélection ET à la liste des formations dans le domaine sélectionné"),
                               # tags$hr(),
                               # 
                               # # --------------------------------
                               # h4("- Visualisation Champs libres "),
                               # p("Visualiser les champs libres pour voir s'ils ont été traités"),
                               # p("lorsque vous avez pris en compte la demande spécifique d'un agent, vous pouvez le sélectionner et le passer en 'Traité'"),
                               # tags$hr(),tags$hr(),
                               # 
                               # # --------------------------------------------------------------------------------------------------------------
                               # h3("PLANS DE FORMATION ..."),
                               # # --------------------------------
                               # h4("- Par formation"),
                               # p("Tableau récapitulant les agents ayant demandé une formation.
                               #   Ce tableau est, en parallèle, sauvegardé au format .xls."),
                               # br(),
                               # # --------------------------------
                               # h4("- Par agent"),
                               # p("Tableau récapitulant les formations demandées par un agent.
                               #   Ce tableau est, en parallèle, sauvegardé au format .xls."),
                               # tags$hr(),tags$hr(),
                               # 
                               # # --------------------------------------------------------------------------------------------------------------
                               # h3("FICHES INDIVIDUELLES"),
                               # p("Ce panneau permet, d'une part, de générer l'ensemble des fiches individuelles de formations
                               #   et, d'autre part, d'afficher la fiche individuelle d'un agent en particulier."),
                               # tags$hr(),tags$hr(),
                               # 
                               # p("Ces 3 tableaux sont sauvegardés dans le répertoire 'Donnees/Outputs (de votre unité) mais ils nécessitent une mise en forme 'manuelle'"),
                               # p("une future mise à jour du programme devrait permettre d'automatiser cette mise en forme"),
                               # 
                               # # --------------------------------------------------------------------------------------------------------------
                               # h3("STATISTIQUES"),
                               # p("Panneau permettant de visualiser quelques statistiques simples."),
                               # # --------------------------------
                               # 
                               # # --------------------------------------------------------------------------------------------------------------
                               # h3("... PARAMETRAGE INITIAL ..."),
                               # p("Chargement de la table de données issues de Lime Survey. A n'effectuer qu'une fois.
                               #   Cette action permet d'importer les données et de structurer la table
                               #   (ordre des variables, uniformisation des noms)."),
                               # p("Cochez la case pour (ré)initialiser le plan de formation"),
                               # p("puis validez en cliquant sur le bouton 'Confirmer la réinitialisation du plan de formation !'"),
                               # br(),
                               # p("cela peut prendre un peu de temps. Lorsque la procédure est terminée, la liste des variables s'affiche. Vous pouvez effectuer une rapide vérification pour vous assurer que tout s'est bien déroulé."),
                               # p("Le bon déroulement de cette étape est cruciale pour la suite des traitements"),
                               # tags$hr()
                               )
                               ),
                    # tabPanel("SUIVI MAINTENANCE",
                    #          mainPanel(
                    #            h1("Pré-plan de formation")
                    #            ,h3(".  Principales maintenances réalisées")
                    #            ,tags$hr()
                    #            ,p("La création de ce panneau maintenance permet de visualiser les principaux problèmes rencontrés lors du développement et peut-être utile dans le cadre d'une appli 'école'")
                    #            
                    #            ,tags$hr(),
                    #            
                    #            # --------------------------------------------------------------------------------------------------------------
                    #            h3("A L'ETUDE / EN COURS")
                    #            ,p("Améliorer l'apparence des fiches individuelles de formation et permettre leur création au format ODS")
                    #            ,tags$hr(),
                    #            
                    #            h3("02 Janvier 2018")
                    #            ,h5("FICHES INDIVIDUELLES")
                    #            ,p("Pbm pour exécuter l'appli à partir du .bat. Au moment de générer les FI de formation, l'appli se grise")
                    #            ,p("Pbm résolu : Ajout de Sys.setenv(RSTUDIO_PANDOC='C:/Program Files/RStudio/bin/pandoc')")
                    #            ,("Les fiches individuelles de formation dont désormais générées aux formats .doc et html")
                    #            ,p("1 fiche par agent")
                    #            ,tags$hr()
                    #            
                    #            ,h3("19 Décembre 2017")
                    #            ,h5("PLANS DE FORMATION / Par agent")
                    #            ,("Pbm dans l'ordre des colonnes du tableau TabAgents.xlsx : Colonnes Formation1 puis Formation11, Fomration12 avant Formation2 ...")
                    #            ,p("Pbm résolu : renommage des colonnes Formation1 ... Formation9 par Formation01 ... Formation 09")
                    #            ,h5("PLANS DE FORMATION / Par formation")
                    #            ,("Pbm dans l'ordre des colonnes du tableau TabForm.xlsx : Colonnes Agent1 puis Agent11, Agent12 avant Agent2 ...")
                    #            ,p("Pbm résolu : renommage des colonnes Agent1 ... Agent9 par Agent01 ... Agent09")
                    #            ,tags$hr()
                    #            
                    #            ,h3("18 Décembre 2017")
                    #            ,h5("...PARAMETRAGE INITIAL...")
                    #            ,p("le fichier TabAgents d'une unité était 'corrompu' dans le sens où il restait énormément de données dans des colonnes censées être vides (mauvais copier-coller). Cela provoquait des problèmes au moment de la fusion de cette table avec la table de résultats de l'enquêtes (TabSortie_LS).")
                    #            ,p("Pbm résolu : modification du pgm pour ne sélectionner que les colonnes utiles de la baseAgents (les 6 premières)")
                    #            ,tags$hr()
                    #            
                    #            ,h5("AJOUTER DES FORMATIONS")
                    #            ,p("Avant d'ajouter une formation (déjà répertoriée ou nouvelle), il peut être utile de visualiser la liste des formations qui sont déjà répertoriées")
                    #            ,p("Ajout d'un bouton permettant d'afficher/Masquer la liste de l'ensemble des formations")
                    #            ,tags$hr()
                    #            
                    #            ,h5("FICHES INDIVIDUELLES")
                    #            ,p("A la création des fiches individuelles (Fiches individuelles.xlsx), le nom de l'onglet est la concaténation du service et du groupe du N+1 et des nom et prénom de l'agent. Les noms sont trop longs et ils sont donc tronqués.")
                    #            ,p("Pbm en cours de résolution : Les fiches individuelles seront générées sous un autre format (doc, ods, html) avec utilisation du package rmarkdown")
                    #            ,tags$hr()
                    #            
                    #            ,h5("ERGONOMIE DE L'APPLICATION")
                    #            ,p("Réorganisation (regroupement) des panneaux :")
                    #            ,p("- 1 panneau Accueil,")
                    #            ,p("- 3 panneaux permettant d'agir sur les données : AJOUTER DES FORMATIONS, créer des PLANS DE FORMATION (par formation ou par agent) ou générer les fiches individuelles,")
                    #            ,p("- 2 panneaux permettant de visualiser soit les données ('formations demandées' et 'état de traitement des champs libres') soit les statistiques")
                    #            ,p("- 2 panneaux d'information : 'CONSEILS DUTILISATION' et 'SUIVI MAINTENANCE'")
                    #            ,p("- 1 panneau permettant d'initialiser l'application (... PARAMETRAGE INITIAL...)")
                    #            
                    #          )
                    # ),
                    tabPanel("... PARAMETRAGE INITIAL ...",
                             sidebarLayout(
                               sidebarPanel(   
                                 h3("Initialisation / Réinitialisation des données"),
                                 h5("chargement des données issues du questionnaire Lime-Survey, structuration du tableau, renommage des noms de colonnes, création de ListFormation_By_Id.rds"),
                                 tags$hr(),br(),
                                 checkboxInput("ExecutSortie_Ls","Cocher cette case pour (ré)initialiser le plan de formation ..."),
                                 p("(si vous cochez cette case puis validez votre choix, votre plan de formation sera réinitialisé)"),
                                 
                                 tags$hr(),br(),
                                 actionButton("validSortieLs", "Confirmer la réinitialisation du plan de formation !",icon = icon("thumbs-up")),
                                 p("(chargement des données issues du questionnaire Lime-Survey, structuration du tableau ...)"),
                                 tags$hr()
                                 
                               ),
                               mainPanel(
                                 h1("Variables du tableau de données : sorties Lime Survey (LS)"),
                                 tags$hr(), br(),
                                 # verbatimTextOutput("NomVarTabSortieLs"),
                                 textOutput("NbVarSortieLs"),
                                 verbatimTextOutput("NomVarSortieLs")
                               )
                             )
                    )
                               ))
