# Projekt data SQL

## Úvod do projektu
Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.

### Datové sady, které je možné požít pro získání vhodného datového podkladu
### Primární tabulky:

czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.
czechia_price – Informace o cenách vybraných potravin za několikaleté období. Datová sada pochází z Portálu otevřených dat ČR.
czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.
Číselníky sdílených informací o ČR:

czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
czechia_district – Číselník okresů České republiky dle normy LAU.
### Dodatečné tabulky:

countries - Všemožné informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

### Výzkumné otázky:
1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

## Odpovědi na otázky:
**﻿1. Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?**
 
Většina odvětví zaznamenala stabilní růst mezd během celého sledovaného období (2007–2018). Meziroční poklesy byly výjimečné a objevily se jen v některých letech a sektorech, např. v peněžnictví a pojišťovnictví, těžbě či veřejné správě. Nejvyšší meziroční nárůst byl zaznamenán v roce 2008 v odvětví „Výroba a rozvod elektřiny, plynu, tepla a klimatizovaného vzduchu“ a v těžbě (13,8 %). Naopak největší pokles nastal v roce 2013 v peněžnictví a pojišťovnictví (-8,8 %). Přes tyto výkyvy je celkový trend ve všech odvětvích rostoucí.

**2. Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?**

V roce 2006	je možné koupit  1313 kg Chleba konzumního kmínového a 1466 litrů Mléka polotučného pasterovaného. 
V roce 2018 je možné koupit	1365 kg chleba a 1670 litrů mléka.

**3. Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?**

Cukr krystalový má nejnižší průměrný meziroční procentuální nárůst cen, a to -1,92 %. Znamená to, že i když jeho cena v některých letech rostla, celkově dlouhodobě klesala.

- Cukr krystalový -1.92
- Rajská jablka červená kulatá -0.74
- Banány žluté 0.81
- Vepřová pečeně s kostí 0.99
- Přírodní minerální voda uhličitá 1.03
- Šunkový salám	1.86
- Jablka konzumní	2.02
- Pečivo pšeničné bílé	2.20
- Hovězí maso zadní bez kosti	2.54
- Kapr živý	2.60

**4. Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?**

Neexistuje žádný rok, ve kterém by meziroční nárůst cen potravin převýšil růst mezd o více než 10 procent. Nejblíže k této situaci byl rok 2013, kdy byl rozdíl mezi růstem cen potravin a růstem mezd 6,66 %. Naopak v roce 2016 došlo k opačné situaci – mzdy rostly, zatímco ceny potravin meziročně poklesly.

**5. Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?**

Z dostupných dat nevyplývá vztah mezi růstem HDP a růstem mezd nebo cen potravin ve stejném či následujícím roce. Například v roce 2009, kdy HDP výrazně pokleslo (–4.49 %), došlo k prudkému poklesu cen potravin (–7.7 %), zatímco mzdy mírně vzrostly (+3.1 %). To ukazuje, že vývoj HDP nemusí mít přímý ani okamžitý dopad na ceny potravin či mzdy.

![image](https://github.com/user-attachments/assets/da8b2eda-ed7e-465f-9aac-48b56964f447)
















    
