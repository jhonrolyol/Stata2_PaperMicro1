*================
* DOCUMENTACIÓN * --------------------------------------------------------------
*================

* Title: Determinantes de la supervivencia empresarial de la mypes peruanas
*		 ante eventos como la crisis sanitaria.
* Authors: Wilder Santos, Roly Odoñez, Luis Mendiola
* Date: october 29, 2022  


*=========
* PAUTAS * ---------------------------------------------------------------------
*=========

* 1.- Usar "control + s" para guardar el Do-file.
* 2.- Usar "control + n" para crear un nuevo Do-file
* 3.- Usar "control + d" para ejecutar los códigos seleccionado en el Do-file.
* 4.- Usar "control + shift + d" para ejecutar el Do-file hasta el final.
* 5.- Usar "control + r" para ejecutar sin mostrar resultados.

*=========
* REMOVE * ---------------------------------------------------------------------
*=========
 
 cls
 clear all
 set more off
 capture log close
 
*=======
* PATH * -----------------------------------------------------------------------
*=======

 global ubicacion "D:\JR-STATA\Practice\Stata2_PaperMicro1"
 cd "$ubicacion"
 global namexcel = "Resultados y gráficos"
 import excel "a2020_COVID19", she("a2020_COVID19") cellrange(A1:DB930) firstrow clear
 svyset [pw=FACTOR]

*==========================
* Construcción del ubigeo *-----------------------------------------------------
*==========================
 
 des CCDD CCPP CCDI
 gen ubigeo = CCDD + CCPP + CCDI
 tab ubigeo

*======================
* Agregación del CIIU *---------------------------------------------------------
*======================

 desc CIIU DESC_CIIU
 destring CIIU, gen(ciiu_num)

 gen cii=.
 replace cii=1 if ciiu_num>=311 & ciiu_num<=322 
 replace cii=2 if ciiu_num>=510 & ciiu_num<=990
 replace cii=3 if ciiu_num>=1010 & ciiu_num<=3320 
 replace cii=4 if ciiu_num>=3510 & ciiu_num<=3530
 replace cii=5 if ciiu_num>=3600 & ciiu_num<=3900
 replace cii=6 if ciiu_num>=4100 & ciiu_num<=4390
 replace cii=7 if ciiu_num>=4510 & ciiu_num<=4799
 replace cii=8 if ciiu_num>=4911 & ciiu_num<=5320
 replace cii=9 if ciiu_num>=5510 & ciiu_num<=5630
 replace cii=10 if ciiu_num>=5811 & ciiu_num<=6399
 replace cii=11 if ciiu_num>=6411 & ciiu_num<=6630
 replace cii=12 if ciiu_num>=6810 & ciiu_num<=6820
 replace cii=13 if ciiu_num>=6910 & ciiu_num<=7500
 replace cii=14 if ciiu_num>=7710 & ciiu_num<=8299
 
 *=======
 * Note *-----------------------------------------------------------------------
 *=======
	* No hay: Administración pública y defensa; planes de seguridad social 
	* de afiliación obligatoria
 replace cii=15 if ciiu_num>=8510 & ciiu_num<=8550
 replace cii=16 if ciiu_num>=8610 & ciiu_num<=8890
 replace cii=17 if ciiu_num>=9000 & ciiu_num<=9329
 replace cii=18 if ciiu_num>=9411 & ciiu_num<=9609
 
 *=======
 * Note *-----------------------------------------------------------------------
 *=======
	* No hay: Actividades de los hogares como empleadores; actividades 
	* no diferenciadas de los hogares como productores de bienes y servicios 
	* para uso propio
	* No hay: Actividades de organizaciones y órganos extraterritoriales

 recode cii (1=1 "Pesca") (2=2 "Minas y canteras") (3=3 "Manufactureras") (4=4 "Electricidad, gas, vapor y AC") (5=5 "Agua y residuos") (6=6 "Construcción") (7=7 "Comercio y rep. vehicular") (8=8 "Transporte y almacenamiento") (9=9 "Alojamiento y comidas") (10=10 "Info y comu") (11=11 "Finanzas y seguros") (12=12 "Inmobiliarias") (13=13 "Profes. ciencias y téc.") (14=14 "Administrativos y apoyo") (15=15 "Enseñanza") (16=16 "Salud h. y AS") (17=17 "Arte, entret. y recreación") (18=18 "Otros servicios"), gen(ciiu)

 recode ciiu (1=1 "Pesca") (3=2 "Fabricación") (6=3 "Construcción") (2 4 5=4 "Minas, Elec, gas y agua") (7 8 9 10 11 12 13 14=5 "Servicios de mercado") (15 16 17 18=6 "Servicios no comerciales"), gen(sececo)
 
 la var sececo "Actividad económica agregada"

 *=======
 * Note *-----------------------------------------------------------------------
 *=======
	* Servicios de mercado: Comercio; Transporte; Alojamiento y alimentación;
	* y Servicios comerciales y administrativos
	* Servicios no comerciales: Administración pública; 
	* servicios y actividades comunitarios, sociales y de otro tipo.
	
 svy: tab sececo

 graph hbar [pw=FACTOR], over(ciiu) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) bar(1, colo(255 128 0)) ylabel(, nogrid)
 graph save "Gráfico1_ciiu", replace
 graph export "Gráfico1_ciiu.png", as(png) width(800) height(600) replace
 putexcel set "$namexcel", sheet("X1") modify
 putexcel C5=picture("Gráfico1_ciiu.png")

 graph hbar [pw=FACTOR], over(sececo) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) bar(1, colo(255 128 0)) tit("Distribución de empresas" "por actividad económica agregada", color(black)) ylabel(, nogrid) ytitl("%")
 graph save "Gráfico12_sececo", replace
 graph export "Gráfico12_sececo.png", as(png) width(800) height(600) replace
 putexcel set "$namexcel", sheet("X1") modify
 putexcel C25=picture("Gráfico12_sececo.png")

*==================================================
* Codificando a los que reportaron la información *-----------------------------
*==================================================

 tab P_3_3
 recode P_3_3 (1=1 "Propietario") (2=2 "Administrador(a)") (3=3 "Gerente General") (4=4 "Contador") (5=5 "Otro"), gen(cargo)
 la var cargo "Cargo del informante"

 tab P_3_2
 recode P_3_2 (2=1 "Mujer") (1=0 "Hombre") if cargo == 1 | cargo == 2 | cargo == 3, gen(sexo)
 la var sexo "Sexo del informante que toma decisiones"

*=========================================
* Años de funcionamiento de las empresas *-------------------------------------- 
*=========================================

 desc ANIO
 gen yfunc = 2019 - ANIO
 tab yfunc
 la var yfunc "Años de funcionamiento de la empresa" 

 gen yfunc_in=.
 replace yfunc_in=1 if yfunc>=0 & yfunc<=20
 replace yfunc_in=2 if yfunc>=21 & yfunc<=40
 replace yfunc_in=3 if yfunc>=41 & yfunc<=60
 replace yfunc_in=4 if yfunc>=61 & yfunc<=80
 replace yfunc_in=5 if yfunc>=81
 recode yfunc_in (1=1 "Hasta 20 años") (2=2 "De 21 a 40 años") (3=3 "De 41 a 60 años") (4=4 "De 61 a 80 años") (5=5 "Más de 80 años"), gen(yfunc_int)
 la var yfunc_int "Intervalos de años de funcionamiento"
 
*=============================================================
* Estado de la empresa a causa del COVID-19 (810 operativos) *------------------
*=============================================================

recode P_4_1 (1=1 "Operativa") (2=2 "Parcialmente operativa") (3=3 "Inoperativa"), gen(estado)
la var estado "Estado de la empresa que tiene actualemente a consecuencia del COVID-19"
graph pie [pw=FACTOR], over(estado) plabel(_all percent, color(white) size(vlarge)) plabel(3 percent, color(black) size(vlarge)) pie(1, color(0 64 128)) pie(2, color(0 128 255)) pie(3, color(226 197 29)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) legend(regio(lco(white))) titl("Estado de empresas como" "consecuencia del COVID-19" "Segundo Trimestre 2020", size(large) colo(black))
graph export "Gráfico2_estado.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X2") modify
putexcel C5=picture("Gráfico2_estado.png")

*===============================================
* Variación de Ventas con respecto al 2019-IIT *--------------------------------
*===============================================

recode P_4_2 (1=1 "Disminuyó") (2=2 "Aumentó") (3=3 "Se mantiene") (4=4 "No realizó ventas"), gen(varven)
la var varven "Variación de las ventas (S/)"
tab varven
graph hbar [pw=FACTOR], over(varven) blabel(_all percent, color(white) size(vlarge)) bar(1, color(0 64 128)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) legend(regio(lco(white))) titl("Variación de ventas" "como consecuencia del" "COVID-19", size(large) colo(black)) ytitl("Porcentaje de empresas")
graph export "Gráfico3_varventas.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X3") modify
putexcel C5=picture("Gráfico3_varventas.png")

*=================
* Variación en % *--------------------------------------------------------------
*=================

gen varven_porc=P_4_2A if varven==1 | varven==2
replace varven_porc=(-1)*P_4_2A if P_4_2==1
la var varven_porc "Variación % de las ventas"
tab varven_porc

*================================
* Capacidad Instalada Operativa *-----------------------------------------------
*================================

recode P_4_3 (1=1 "Hasta el 20%") (2=2 "Del 21% al 40%") (3=3 "Del 41% al 60%") (4=4 "Del 61% al 80%") (5=5 "Del 81% al 100%"), gen(capins)
la var capins "Uso de la Capacidad Instalada Operativa (2T-2020)"

*=====================
* Modalidad de ventas *---------------------------------------------------------
*=====================

recode P_4_4 (1=1 "Solo presencial") (2=2 "Solo por delivery") (3=3 "Solo online") (4=4 "Presencial y delivery") (5=5 "Otra modalidad"), gen(modtra)
la var modtra "Modalidad de ventas en 2T-2020"
graph bar [pw=FACTOR], over(modtra) blabel(, percent) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) legend(regio(lco(white))) titl("Modalidad de ventas" "de la empresa" "en el Segundo Trimestre 2020", size(large) colo(black)) ytitl("Porcentaje de empresas") bar(1, color(0 64 128)) bar(2, color(116 228 67)) bar(3, color(255 128 0)) bar(4, color(254 22 0)) bar(5, color(128 128 128)) asyv
graph export "Gráfico4_modventas.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X4") modify
putexcel C5=picture("Gráfico4_modventas.png")
svy: tab modtra

*=============================================
* Principales problemas a causa del COVID-19 *----------------------------------
*=============================================

	forvalue i=1/13 {
	*svyset [pw=FACTOR]
	tab P_4_5_`i'
	}

graph bar P_4_5_1 P_4_5_2 P_4_5_3 P_4_5_4 P_4_5_5 P_4_5_6 P_4_5_7 P_4_5_8 P_4_5_9 P_4_5_10 P_4_5_11 P_4_5_12 P_4_5_13 [pw=FACTOR]
gen pro_disdem=P_4_5_1
lab define pro_disdem 1 "Si" 0 "No"
la value pro_disdem pro_disdem
la var pro_disdem "Disminución de la demanda de su producto o servicio"
gen pro_parpro=P_4_5_2
lab define pro_parpro 1 "Si" 0 "No"
la value pro_parpro pro_parpro
la var pro_parpro "Paralización de la producción a causa de la pandemia"
gen pro_desmpn=P_4_5_4
lab define pro_desmpn 1 "Si" 0 "No"
la value pro_desmpn pro_desmpn
la var pro_desmpn "Desabastecimiento de materias primas e insumos del mercado nacional"
gen pro_desmpe=P_4_5_5
lab define pro_desmpe 1 "Si" 0 "No"
la value pro_desmpe pro_desmpe
la var pro_desmpe "Desabastecimiento de materias primas e insumos del extranjero"
gen pro_retpfac=P_4_5_7
lab define pro_retpfac 1 "Si" 0 "No"
la value pro_retpfac pro_retpfac
la var pro_retpfac "Retraso en el pago de facturas"
gen pro_retcfac=P_4_5_8
lab define pro_retcfac 1 "Si" 0 "No"
la valu pro_retcfac pro_retcfac
la var pro_retcfac "Retraso en el cobro de facturas"
gen pro_enftra=P_4_5_9
lab define pro_enftra 1 "Si" 0 "No"
la value pro_enftra pro_enftra
la var pro_enftra "Enfermedad de trabajadores por el COVID-19"
gen pro_perkt=P_4_5_10
lab define pro_perkt 1 "Si" 0 "No"
la value pro_perkt pro_perkt
la var pro_perkt "Pérdida de capital de trabajo"
gen pro_acseg=P_4_5_11
lab define pro_acseg 1 "Si" 0 "No"
la valu pro_acseg pro_acseg
la var pro_acseg "Altos costos para implementar planes de seguridad "

foreach x of varlist pro_disdem pro_desmpn pro_desmpe pro_parpro pro_retpfac pro_retcfac pro_enftra pro_perkt pro_acseg {
svyset [pw=FACTOR]
svy: tab `x'
}

graph bar (sum) pro_disdem pro_parpro pro_retpfac pro_retcfac pro_enftra pro_perkt pro_acseg pro_desmpn pro_desmpe [pw=FACTOR], xsize(10) ysize(8) blabe(total, format(%12.0f)) bargap(10) bar(5) legend(order(1 "Disminución de" "demanda" 7 "Altos costos" "para segurirdad" 2 "Paralización de" "la producción" 4 "Retraso de cobro" "de facturas"   3 "Retraso en pago" "de facturas" 6 "Pérdidas de" "capital de trabajo" 8 "Desabastecimiento" "materia prima" "nacional" 9 "Desabastecimiento" "de materia prima" "extranjera"  5 "COVID-19 en" "trabajadores" ) regio(lco(white)) size(small)  col(3) row(3)) bar(1, color(0 64 128)) bar(2, color(116 228 67)) bar(3, color(255 128 0)) bar(4, color(254 22 0)) bar(5, color(128 128 128)) bar(6, color(0 128 255)) bar(7, color(226 197 29)) bar(8, color(70 166 202)) bar(9, color(255 128 64)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) ylabel(, nogrid) title("¿Cuáles son los principales" "problemas que enfrentó por" "el COVID-19 en el 2020-2T", color(black)) ytitle("") ylabel(none) yvar(sort(9) descen)
graph save "Gráfico5_problemas", replace 
graph export "Gráfico5_problemas.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X5") modify
putexcel C5=picture("Gráfico5_problemas.png")

	* 240194 total expandido 
	svy: tab estado
	svy: tab estado if P_5_1!=1
	*211441
	*181466 de empresas en la sección IV
	svy: tab pro_disdem
	dis 0.6992*211441
	*126881 de empresas con el problema 1
	**Valores coinciden con el gráfico

*====================================================	
* Trabajadores que laboraron en el segundo "T-2020" *---------------------------
*====================================================

	tab P_4_6
	recode P_4_6 (1=1 "Hasta 20%") (2=2 "De 21 a 40%") (3=3 "De 41 a 60%") (4=4 "De 61 a 80%") (5=5 "De 81 a 100%"), gen(trbcvd19)
	svy: tab trbcvd19

*========================================================	
* Modalidad de trabajadores que laboraron en el 2T-2020 *-----------------------
*========================================================

	tab P_4_7
	recode P_4_7 (1=1 "Sólo trabajo presencial") (2=2 "Sólo trabajo remoto") (3=3 "Trabajo mixto"), gen(modtrabnv)
	la var modtrabnv "Modalidad de trabajo que se adoptó por el COVID-19"
	svy: tab modtrabnv

*Medidas adoptadas por las empresas con los trabajadores 2T-2020
tab1 P_4_8_*
desc P_4_8_8 P_4_8_12
destring P_4_8_12, gen(P_4_8_12correg) 
graph bar (sum) P_4_8_1 P_4_8_2 P_4_8_3 P_4_8_4 P_4_8_5 P_4_8_6 P_4_8_7 P_4_8_8 P_4_8_9 P_4_8_10 P_4_8_11 P_4_8_12correg [pw=FACTOR]
 
gen medL_norev=P_4_8_1
lab define medL_norev 1 "Si" 0 "No"
la valu medL_norev medL_norev
la var medL_norev "No renovación de contratos"
gen medL_felxh=P_4_8_2
lab define medL_felxh 1 "Si" 0 "No"
la value medL_felxh medL_felxh
la var medL_felxh "Flexibilidad de los horarios"
gen medL_redhs=P_4_8_3
lab define medL_redhs 1 "Si" 0 "No"
la value medL_redhs medL_redhs
la var medL_redhs "Reducción de horas trabajadas en la semana"
gen medL_vacade=P_4_8_4
replace medL_vacade=. if P_4_8_4==4
lab define medL_vacade 1 "Si" 0 "No"
lab value medL_vacade medL_vacade
la var medL_vacade "Vacaciones adelantadas"
gen medL_redrem=P_4_8_7
lab define medL_redrem 1 "Si" 0 "No"
la value medL_redrem medL_redrem
la var medL_redrem "Reducción de Remuneraciones"
gen medL_subDU=P_4_5_9
lab define medL_subDU 1 "Si" 0 "No"
la value medL_subDU medL_subDU
la var medL_subDU "Subsidio a la planilla por Decreto de Urgencia (35%)"
gen medL_noado=P_4_5_10
lab define medL_noado 1 "Si" 0 "No"
la value medL_noado medL_noado
la var medL_noado "No adoptó medidas"

graph bar (sum) medL_norev medL_felxh medL_redhs medL_vacade medL_redrem medL_subDU medL_noado [pw=FACTOR], xsize(10) ysize(8) blabe(total, format(%12.0f)) bargap(10) bar(5) legend(order(2 "Flexibilidad de" "los horarios" 7 "No adoptó medidas" 3 "Reducción de horas" "trabajadas en la semana" 6 "Subsidio a la" "planilla por" "DU (35%)" 4 "Vacaciones" "adelantadas" 5 "Reducción de" "Remuneraciones"  1 "No renovación" "de contratos" ) regio(lco(white)) size(small)  col(3) row(3)) bar(1, color(0 64 128)) bar(2, color(116 228 67)) bar(3, color(255 128 0)) bar(4, color(254 22 0)) bar(5, color(128 128 128)) bar(6, color(0 128 255)) bar(7, color(226 197 29)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) ylabel(, nogrid) title("¿Cuáles fueron las principales" "medidas que se tomó" "con los trabajadores en el 2020-2T?", color(black)) ytitle("") ylabel(none) yvar(sort(7) descen)
graph save "Gráfico6_medidasL", replace 
graph export "Gráfico6_medidasL.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X6") modify
putexcel C5=picture("Gráfico6_medidasL.png")

*==============
* C: Finanzas *-----------------------------------------------------------------
*==============

*Se presentaron problemas financieros como:
tab1 P_4_9_*
graph bar P_4_9_1 P_4_9_2 P_4_9_3 P_4_9_4 P_4_9_5 P_4_9_6 P_4_9_7 P_4_9_8 P_4_9_9 [pw=FACTOR], yline(0.2)
gen probf_difacp=P_4_9_1
lab define probf_difacp 1 "Si" 0 "No"
la value probf_difacp probf_difacp
la var probf_difacp "Difícil accesibilidad a créditos de sus proveedores"
gen probf_fliqcom=P_4_9_2
lab define probf_fliqcom 1 "Si" 0 "No"
la value probf_fliqcom probf_fliqcom
la var probf_fliqcom "Falta de liquidez para la compra de insumos o materias primas"
gen probf_limacff=P_4_9_3
lab define probf_limacff 1 "Si" 0 "No"
la value probf_limacff probf_limacff
la var probf_limacff "Limitaciones para acceder a fuentes de financiamiento"
gen probf_fliqpr=P_4_9_4
lab define probf_fliqpr 1 "Si" 0 "No"
la value probf_fliqpr probf_fliqpr
la var probf_fliqpr "Falta de liquidez para pagar remuneraciones del personal"
gen probf_difppf=P_4_9_5
lab define probf_difppf 1 "Si" 0 "No"
la value probf_difppf probf_difppf
la var probf_difppf "Dificultad para pagar préstamos al sistema financiero"
gen probf_fliqpp=P_4_9_6
lab define probf_fliqpp 1 "Si" 0 "No"
la value probf_fliqpp probf_fliqpp
la var probf_fliqpp "Falta de liquidez para pagar a proveedores"
gen probf_difcc=P_4_9_7
lab define probf_difcc 1 "Si" 0 "No"
la value probf_difcc probf_difcc
la var probf_difcc "Dificultad para cobrar a sus clientes"

graph bar (sum) probf_difacp probf_fliqcom probf_limacff probf_fliqpr probf_difppf probf_fliqpp probf_difcc [pw=FACTOR], xsize(10) ysize(8) blabe(total, format(%12.0f)) bargap(10) bar(5) legend(order(7 "Dificultad para" "cobrar a sus" "clientes" 3 "Limitaciones para" "acceder a fuentes" "de financiamiento" 2 "Falta de liquidez" "para la compra" "de insumos" 6 "Falta de liquidez" "para pagar" "a proveedores" 4 "Falta de liquidez" "para pagar" "remuneraciones" 5 "Dificultad para" "pagar préstamos al" "sistema financiero" 1 "Difícil accesibilidad" "a créditos de sus" "proveedores") regio(lco(white)) size(small)  col(3) row(3)) bar(1, color(0 64 128)) bar(2, color(116 228 67)) bar(3, color(255 128 0)) bar(4, color(254 22 0)) bar(5, color(128 128 128)) bar(6, color(0 128 255)) bar(7, color(226 197 29)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) ylabel(, nogrid) title("¿Cuáles fueron los principales" "problemas financieros" "que presentó en el 2020-2T?" " ", color(black)) ytitle("") ylabel(none) yvar(sort(7) descen)
graph save "Gráfico7_problemasf", replace 
graph export "Gráfico7_problemasf.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X7") modify
putexcel C5=picture("Gráfico7_problemasf.png")


*==========================
* D:Sección de percepción *-----------------------------------------------------
*==========================

*E:Acceso a programas del Gobierno

tab1 P_4_12_*
desc P_4_12_1 P_4_12_2 P_4_12_3 P_4_12_4 P_4_12_5 P_4_12_6 P_4_12_7 P_4_12_8 P_4_12_9 P_4_12_10 P_4_12_11 P_4_12_12 P_4_12_13 P_4_12_14 P_4_12_15
destring P_4_12_15, gen(P_4_12_15correg)
graph bar (sum) P_4_12_1 P_4_12_2 P_4_12_3 P_4_12_4 P_4_12_5 P_4_12_6 P_4_12_7 P_4_12_8 P_4_12_9 P_4_12_10 P_4_12_11 P_4_12_12 P_4_12_13 P_4_12_14 P_4_12_15correg [pw=FACTOR], yline(20000)

*Acceso a programas del gobierno
egen progob_acc=anymatch(P_4_12_1 P_4_12_2 P_4_12_3 P_4_12_4 P_4_12_5 P_4_12_6 P_4_12_7 P_4_12_8 P_4_12_9 P_4_12_10 P_4_12_11 P_4_12_12 P_4_12_13), value(1)  
tab progob_acc
recode progob_acc (1=1 "Si") (0=0 "No"), gen(progob_acceso)
la var progob_acceso "¿Accedió a algún programa del gobierno"
svy: tab ciiu progob_acceso
estimate store table1 /*exportan la table1 .doc*/
ssc install outreg2  /*exportan la table1 .doc*/ 
outreg2 [table1] using result.doc, replace /*exportan la table1 .doc*/


graph pie [pw=FACTOR] if ciiu==3 | ciiu==6 | ciiu==7 | ciiu==8 | ciiu==9, over(progob_acceso) by(ciiu) pie(1, color(0 128 255)) pie(2, explode color(253 198 30)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white))
*Problemas con el título---> title("Acceso a programas del" "gobierno por principales sectores" "por número de empresas")
graph save "Gráfico8_progragobiacce", replace 
graph export "Gráfico8_progragobiacce.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X8") modify
putexcel C5=picture("Gráfico8_progragobiacce.png")

*3 6 7 8 9
*Programas del gobierno
recode P_4_12_1 (1=1 "Si") (0=0 "No"), gen(progob_spl)
la var progob_spl "Suspensión perfecta de labores"
recode P_4_12_2 (1=1 "Si") (0=0 "No"), gen(progob_sub35)
la var progob_sub35 "Subsidio del 35% para los trabajadores que ganen hasta 1500 soles"
recode P_4_12_3 (1=1 "Si") (0=0 "No"), gen(progob_appt)
la var progob_appt "Ampliación de plazos para reconocimiento de perdidas tributarias"
recode P_4_12_5 (1=1 "Si") (0=0 "No"), gen(progob_raf)
la var progob_raf "Régimen de aplazamiento y/o fraccionamiento (RAF) de deudas tributarias"
recode P_4_12_6 (1=1 "Si") (0=0 "No"), gen(progob_mayplat)
la var progob_mayplat "Mayores plazos de pago para deudas tributarias vencidas o por vencer"
recode P_4_12_7 (1=1 "Si") (0=0 "No"), gen(progob_detpgct)
la var progob_detpgct "Determinación de pagos a cuentas del impuesto a la renta (suspender o modificar)"
recode P_4_12_8 (1=1 "Si") (0=0 "No"), gen(progob_react)
la var progob_react "Reactiva Perú"
recode P_4_12_14 (1=1 "Si") (0=0 "No"), gen(progob_noacce)
la var progob_noacce "No accedió a ningún programa o medida del gobierno"

graph bar (sum) progob_spl progob_sub35 progob_appt progob_raf progob_mayplat progob_detpgct progob_react progob_noacce [pw=FACTOR], xsize(10) ysize(8) blabe(total, format(%12.0f)) bargap(10) bar(5) legend(order( 8 "No accedió a ningún" "programa o medida" "del gobierno"  7 "Reactiva Perú" 1 "Suspensión perfecta" "de labores" 2 "Subsidio del 35%" "para los trabajadores" "que ganen hasta 1500 soles" 5 "Mayores plazos de pago" "para deudas tributarias" "vencidas o por vencer" 3 "Ampliación de plazos" "para reconocimiento" "de perdidas tributarias"  4 "Régimen de" "aplazamiento y/o" "fraccionamiento de" "deudas tributarias" 6 "Determinación de pagos" "a cuentas del impuesto a" "la renta (suspender o modificar)") regio(lco(white)) size(vsmall)  col(3) row(3)) bar(1, color(0 64 128)) bar(2, color(116 228 67)) bar(3, color(255 128 0)) bar(4, color(254 22 0)) bar(5, color(128 128 128)) bar(6, color(0 128 255)) bar(7, color(226 197 29)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) ylabel(, nogrid) title("¿A qué programa del gobierno accedió?" " ", color(black)) ytitle("") ylabel(none) yvar(sort(8) descen)
graph save "Gráfico9_proggob", replace 
graph export "Gráfico9_proggob.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X9") modify
putexcel C5=picture("Gráfico9_proggob.png")

*=================================
* Sección V: Empresa Inoperativa *----------------------------------------------
*=================================

*Desde cuando se encuentra inoperativa (se consideran para el análisis las que dejaron de operar desde el 16 de marzo)

tab P_5_1
recode P_5_1 (1=1 "Antes del 16 de marzo de 2020") (2=2 "Del 16 de marzo a junio de 2020"), gen(tinoper)
la var tinoper "¿Desde cuándo se encuentra inoperativa la empresa?"

*Motivos de inoperatividad
tab1 P_5_2_*
desc P_5_2_1 P_5_2_2 P_5_2_3 P_5_2_4 P_5_2_5 P_5_2_6 P_5_2_7 P_5_2_8 P_5_2_9 P_5_2_10 P_5_2_10_O P_5_2_11
destring P_5_2_11, gen(P_5_2_11correg)
graph bar (sum) P_5_2_1 P_5_2_2 P_5_2_3 P_5_2_4 P_5_2_5 P_5_2_6 P_5_2_7 P_5_2_8 P_5_2_9 P_5_2_10 P_5_2_11correg, yline(15)

recode P_5_2_1 (1=1 "Si") (0=0 "No"), gen(inop_noaut)
la var inop_noaut "No tiene autorización"
recode P_5_2_2 (1=1 "Si") (0=0 "No"), gen(inop_percli)
la var inop_percli "Pérdida de clientes"
recode P_5_2_4 (1=1 "Si") (0=0 "No"), gen(inop_dicure)
la var inop_dicure "Dificultad para cumplir con los clientes"
recode P_5_2_5 (1=1 "Si") (0=0 "No"), gen(inop_pektra)
la var inop_pektra "Pérdida de capital de trabajo"
recode P_5_2_7 (1=1 "Si") (0=0 "No"), gen(inop_difin)
la var inop_difin "Dificultades para el financiamiento"
graph hbar (sum) inop_noaut inop_percli inop_dicure inop_pektra inop_difin [pw=FACTOR] if estado==3, over(yfunc_int) legend(label(1 "Sin autorización") label(2 "Pérdidas de clientes") label(3 "Dificultad para" "cumplir con los" "clientes") label(4 "Pérdida de capital" "de trabajo") label(5 "Dificultades de" "financiamiento") region(color(white))) stack percent bar(1, color(0 64 128)) bar(2, color(0 128 255)) bar(3, color(255 128 0)) bar(4, color(226 197 29)) bar(5, color(128 128 128)) plotregio(color(white) icolor(white) fcolor(white)) graphregion(fcolor(white)) titl("Motivos por los cuales" "dejaron de operar iniciada la pandemia", color(black)) ylabel(, labsize(small))
graph save "Gráfico10_motinop", replace 
graph export "Gráfico10_motinop.png", as(png) width(800) height(600) replace
putexcel set "$namexcel", sheet("X10") modify
putexcel C5=picture("Gráfico10_motinop.png")

*=========================
* A.1 TEST DE ASOCIACIÓN *------------------------------------------------------
*=========================

	recode estado (1 2=1 "Si") (3=0 "No"), gen(estado1)
	la var estado "Estado de la empresa: Operativo o inoperativo"

	svyset [pw=FACTOR]

*Para variables cuantitativas
scalar a0=1
foreach x of varlist yfunc varven_porc{
	replace `x'=. if `x'==-9
	svy: mean `x', over(estado1) coeflegend
	test _b[c.`x'@0bn.estado1] = _b[c.`x'@1.estado1]
	if `=a0'==1 {
		scalar matresl="RESULTestado1"
		mat matresl=J(1,1,.)
		matrix rownames matresl="`x'"
		mat matresl[1,1]=r(p)
	}
	else {
		mat matresl1=J(1,1,.)
		matrix rownames matresl1="`x'"
		mat matresl1[1,1]=r(p)
		mat matresl=matresl\matresl1
	}
	scalar a0=a0+1
}
mat list matresl
estimate store matrix1 /*Para exportar la matrix1 .doc*/
outreg2[matrix1] using matriz1.doc, replace /*Para exportar matrix1 .doc*/



*Se está revisando para exportar los resultados
*putexcel set "$namexcel", sheet("X11") modify
*putexcel B5=("p") using "$namexcel", replace
*putexcel A2=matrix(c1) using results, modify

/*
				c1
yfunc		.09748044
varven_porc	.00006435

La variable de años de funcionamiento presenta asociación con la variable de estado con 99% de confianza; mientras que, la de años de funcionamiento presenta asociación individual al 90% de confianza.
*/
svyset [pw=FACTOR]

scalar a0=1
foreach x of varlist sececo modtra modtrabnv pro_disdem pro_parpro pro_retpfac pro_retcfac pro_enftra pro_perkt pro_acseg medL_norev medL_felxh medL_redhs medL_vacade medL_redrem medL_subDU medL_noado probf_fliqcom probf_fliqpr probf_fliqpr probf_fliqpp probf_difcc progob_acceso progob_spl progob_sub35 progob_appt progob_raf progob_mayplat progob_detpgct progob_react progob_noacce {
	*replace `x'=. if `x'==-9
	svy: tab  `x' estado1, col pearson ci
	if `=a0'==1 {
		scalar matresl="RESULTestado1"
		mat matresl=J(1,1,.)
		matrix rownames  matresl="`x'"
		mat matresl[1,1]=e(p_Pear)
	}
	else {
		mat matresl1=J(1,1,.)
		matrix rownames  matresl1="`x'"
		mat matresl1[1,1]=e(p_Pear)
		mat matresl=matresl\matresl1
	}
	scalar a0=a0+1
}
mat list matresl
estimate store matrix2 /*Para exportar la matrix1 .doc*/
outreg2[matrix2] using matriz2.doc, replace /*Para exportar matrix1 .doc*/




/*
matresl[31,1]
				c1
sececo			.21545099
modtra			.57361867
modtrabnv		.03997966
pro_disdem		.58309259
pro_parpro		.48203332
pro_retpfac		.04631159
pro_retcfac		.09676195
pro_enftra		.13308837
pro_perkt		.21226247
pro_acseg		.07648971
medL_norev		.33129479
medL_felxh		8.231e-06
medL_redhs		.0002275
medL_vacade		.18319044
medL_redrem		.22241051
medL_subDU		.13308837
medL_noado		.21226247
probf_fliq~m	.31759738
probf_fliqpr	.38157546
probf_fliqpr	.38157546
probf_fliqpp	.16197277
probf_difcc		.01669375
progob_acc~o	6.318e-06
progob_spl		.00906206
progob_sub35	.2533927
progob_appt		.70667949
progob_raf		.13181745
progob_may~t	.14097632
progob_det~t	3.173e-07
progob_react	.10055116
progob_noa~e	.08496665

EL CIIU no es significativo, pero deberíamos considerarlo por la evidencia empírica (referenciar antecedentes); otras variables que presentan asociación son: modtrabnv** , pro_retpfac** , pro_retcfac* ,
pro_acseg* , medL_felxh*** , medL_redhs***, probf_difcc**, progob_acc~o*** , progob_spl***, progob_det~t***, progob_react, progob_noa~e*

*** al 99% de confianza
** al 95% de confianza
* al 90% de confianza

A partir de las variables que tienen cierta asociación individual se pueden plantear diversas especificaciones, que deben estar sustentadas con la teoría para poder comprarar modelos

*/

*============================
* Especificación de modelos *---------------------------------------------------
*============================

*===========
* Modelo 1 *--------------------------------------------------------------------
*===========

	logit estado1 i.sececo yfunc 
	estimate store Modelo1

*===========
* Modelo 2 *--------------------------------------------------------------------
*===========

	logit estado1 i.sececo yfunc varven_porc 
	estimate store Modelo2
	
*===========	
* Modelo 3 *--------------------------------------------------------------------
*===========

	logit estado1 i.sececo yfunc varven_porc i.modtrab 
	estimate store Modelo3

*==========
* Modelo 4 *--------------------------------------------------------------------
*==========

	logit estado1 i.sececo yfunc varven_porc i.modtrab pro_retpfac
	estimate store Modelo4

*===========
* Modelo 5 *--------------------------------------------------------------------
*===========

	logit estado1 i.sececo yfunc varven_porc i.modtrab pro_retpfac pro_retcfac 
	estimate store Modelo5
	
*===========
* Modelo 6 *--------------------------------------------------------------------
*===========

	logit estado1 i.sececo yfunc varven_porc i.modtrab pro_retpfac medL_redhs medL_felxh 
	estimate store Modelo6

*===========	
* Modelo 7 *--------------------------------------------------------------------
*===========

	logit estado1 yfunc varven_porc i.modtrab pro_retpfac medL_redhs medL_felxh progob_acceso 
	estimate store Modelo7
	
*===========	
* Modelo 8 *--------------------------------------------------------------------
*===========

	svy: logit estado1 yfunc varven_porc i.modtrab pro_retpfac medL_redhs medL_felxh progob_acceso progob_detpgct 
	estimate store Modelo8
	
*===========	
* Modelo 9 *--------------------------------------------------------------------
*===========

	logit estado1 yfunc varven_porc i.modtrab pro_retpfac medL_felxh progob_acceso progob_detpgct
	estimate store Modelo9
	outreg2[Modelo1 Modelo2 Modelo3 Modelo4 Modelo5 Modelo6 Modelo7 Modelo8 Modelo9] using resultado.doc, replace /*Para exportar resultado .doc*/
	outreg2[Modelo1 Modelo2 Modelo3 Modelo4 Modelo5] using resultado.doc, replace /*Para exportar resultado .doc*/
	est table Modelo1 Modelo2 Modelo3 Modelo4 Modelo5 Modelo6 Modelo7 Modelo8 Modelo9 , stat(aic bic) 

*======================
* Mejor modelo por CI *---------------------------------------------------------
*======================

*===========
* Modelo 3 *--------------------------------------------------------------------
*===========

	logit estado1 i.sececo yfunc varven_porc i.modtrab 
	
*===========
* Modelo 7 *--------------------------------------------------------------------
*===========

	logit estado1 yfunc varven_porc i.modtrab pro_retpfac medL_redhs medL_felxh progob_acceso 

*===========
* Modelo 9 *--------------------------------------------------------------------
*===========

	logit estado1 yfunc varven_porc i.modtrab pro_retpfac medL_felxh progob_acceso progob_detpgct

* progob_react 
* progob_spl 
* probf_difcc pro_retcfac pro_acseg 

