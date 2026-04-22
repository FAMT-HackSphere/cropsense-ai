def analyze_nitrogen(n: float, crop: str) -> str:
    if n is None: return "Nitrogen data unavailable."
    if n < 40:
        cat, mean, imp = "low fertility range (< 40 kg/ha)", "Nitrogen supports vegetative growth and chlorophyll production.", "This deficit may limit overall vegetative development, requiring supplemental fertilization."
    elif n <= 80:
        cat, mean, imp = "moderate fertility range (40-80 kg/ha)", "Nitrogen supports vegetative growth and chlorophyll production.", "This level supports balanced crop growth and moderate yield potential."
    else:
        cat, mean, imp = "high fertility range (> 80 kg/ha)", "Nitrogen supports vegetative growth and chlorophyll production.", "This abundance ensures robust vegetative activity but may risk overgrowth at the expense of fruiting."
    return f"The soil nitrogen level is {n:.1f} kg/ha, which falls under the {cat}. {mean} {imp}"

def analyze_phosphorus(p: float, crop: str) -> str:
    if p is None: return "Phosphorus data unavailable."
    if p < 25:
        cat, mean, imp = "low availability range (< 25 kg/ha)", "Phosphorus is critical for root development and energy transfer (ATP).", "Low levels may cause stunted root systems, requiring targeted P applications."
    elif p <= 50:
        cat, mean, imp = "moderate availability range (25-50 kg/ha)", "Phosphorus is critical for root development and energy transfer (ATP).", "This concentration provides adequate support for early root proliferation and flowering."
    else:
        cat, mean, imp = "high availability range (> 50 kg/ha)", "Phosphorus is critical for root development and energy transfer (ATP).", "High availability enables rapid early growth and robust reproductive phase stability."
    return f"The soil phosphorus level is {p:.1f} kg/ha, classifying it within the {cat}. {mean} {imp}"

def analyze_potassium(k: float, crop: str) -> str:
    if k is None: return "Potassium data unavailable."
    if k < 150:
        cat, mean, imp = "low concentration range (< 150 kg/ha)", "Potassium regulates stomatal opening, enzyme activation, and disease resistance.", "Sub-optimal levels could increase susceptibility to drought stress and diseases."
    elif k <= 250:
        cat, mean, imp = "moderate concentration range (150-250 kg/ha)", "Potassium regulates stomatal opening, enzyme activation, and disease resistance.", "This level properly mediates water use efficiency and general crop resilience."
    else:
        cat, mean, imp = "high concentration range (> 250 kg/ha)", "Potassium regulates stomatal opening, enzyme activation, and disease resistance.", "Excessively high levels ensure excellent stress tolerance, though balance with other cations is necessary."
    return f"The soil potassium level is {k:.1f} kg/ha, placing it in the {cat}. {mean} {imp}"

def analyze_ph(ph: float, crop: str) -> str:
    if ph is None: return "pH data unavailable."
    if ph < 6.5:
        cat, mean, imp = "acidic range (< 6.5)", "Soil pH controls nutrient solubility and microbial activity.", "Acidic conditions may lock up phosphorus and micronutrients, slightly stressing sensitive crops."
    elif ph <= 7.5:
        cat, mean, imp = "neutral range (6.5-7.5)", "Soil pH controls nutrient solubility and microbial activity.", "Neutral pH offers optimal overall nutrient bioavailability, ideal for most crop systems."
    else:
        cat, mean, imp = "alkaline range (> 7.5)", "Soil pH controls nutrient solubility and microbial activity.", "Alkaline levels can inhibit the uptake of iron and zinc, necessitating specific soil amendments."
    
    # Crop specific matching
    crop_match = ""
    if crop.lower() == "rice" and 6.0 <= ph <= 7.5:
         crop_match = f" A pH of {ph:.1f} falls directly within the optimal range (6.0-7.5) for {crop.capitalize()} cultivation."
         
    return f"The soil pH is {ph:.1f}, placing it in the {cat}. {mean} {imp}{crop_match}"

def analyze_rainfall(rain: float, crop: str) -> str:
    if rain is None: return "Rainfall data unavailable."
    if rain < 500:
        cat, mean, imp = "low precipitation category (< 500 mm)", "Rainfall drives the primary soil moisture recharge dynamic for rainfed agriculture.", "This dry environment necessitates heavily managed supplementary irrigation."
    elif rain <= 800:
        cat, mean, imp = "moderate precipitation category (500-800 mm)", "Rainfall drives the primary soil moisture recharge dynamic for rainfed agriculture.", "This range supports consistent moisture availability without persistent waterlogging."
    else:
        cat, mean, imp = "high precipitation category (> 800 mm)", "Rainfall drives the primary soil moisture recharge dynamic for rainfed agriculture.", "Significant rainfall maintains high soil saturation, though drainage systems must be monitored."
        
    # Crop specific matching
    crop_match = ""
    if crop.lower() == "rice":
        if 600 <= rain <= 1200:
             crop_match = f" Additionally, this rainfall level of {rain:.1f} mm falls perfectly within the ideal range (600-1200 mm) for {crop.capitalize()} cultivation."
             
    return f"The recorded rainfall is {rain:.1f} mm, categorized under the {cat}. {mean} {imp}{crop_match}"

def analyze_temperature(temp: float, crop: str) -> str:
    if temp is None: return "Temperature data unavailable."
    if temp < 20:
        cat, mean, imp = "low thermal margin (< 20C)", "Temperature governs the metabolic rate of both the crop and soil microbiology.", "Cooler conditions slow down germination and overall metabolic speed."
    elif temp <= 35:
        cat, mean, imp = "optimal thermal margin (20-35C)", "Temperature governs the metabolic rate of both the crop and soil microbiology.", "These ideal temperatures maximize photosynthetic efficiency and healthy physiological growth."
    else:
        cat, mean, imp = "high thermal margin (> 35C)", "Temperature governs the metabolic rate of both the crop and soil microbiology.", "Heat stress can severely impact enzymatic processes and cause rapid evapotranspiration."
        
    crop_match = ""
    if crop.lower() == "rice" and 25 <= temp <= 35:
         crop_match = f" The ambient temperature of {temp:.1f}C natively satisfies {crop.capitalize()}'s requirement range (25-35C), significantly increasing the crop suitability score."
         
    return f"The ambient temperature is {temp:.1f}°C, situating it in the {cat}. {mean} {imp}{crop_match}"

def analyze_humidity(hum: float, crop: str) -> str:
    if hum is None: return "Humidity data unavailable."
    if hum < 50:
        cat, mean, imp = "low atmospheric saturation zone (< 50%)", "Humidity influences the vapor pressure deficit, limiting or accelerating crop transpiration.", "Dry air increases crop water loss demands, increasing irrigation dependency."
    elif hum <= 75:
        cat, mean, imp = "moderate atmospheric saturation zone (50-75%)", "Humidity influences the vapor pressure deficit, limiting or accelerating crop transpiration.", "Balanced humidity ensures efficient stomatal regulation while mitigating intense fungal pressures."
    else:
        cat, mean, imp = "high atmospheric saturation zone (> 75%)", "Humidity influences the vapor pressure deficit, limiting or accelerating crop transpiration.", "Elevated moisture strictly limits evapotranspiration but considerably increases the risk of pathogenic fungal outbreaks."
    return f"The relative humidity is {hum:.1f}%, identifying it in the {cat}. {mean} {imp}"

def analyze_soil_type(soil: str, crop: str) -> str:
    if not soil: return "Soil type data unavailable."
    slower = soil.lower()
    if "loam" in slower or "loamy" in slower:
        return f"{soil.capitalize()} soil provides balanced drainage and moisture retention, making it highly suitable for diverse crops and root expansion."
    elif "clay" in slower:
        return f"{soil.capitalize()} soil retains water highly efficiently and offers sustained nutrient hold, but may require strict drainage management to prevent hypoxia."
    elif "sand" in slower or "sandy" in slower:
        return f"{soil.capitalize()} soil drains quickly providing exceptional aeration, though it may require frequent irrigation intervals and careful nutrient tracking due to leaching."
    return f"The {soil.capitalize()} soil type offers unique agronomic qualities requiring specific management."

def generate_scientific_explanation(data: dict, recommended_crop: str) -> str:
    """
    Generates a highly structured, scientifically rigorous explanation 
    of the agricultural suitability for a selected crop.
    """
    n = data.get("nitrogen")
    p = data.get("phosphorus")
    k = data.get("potassium")
    ph = data.get("ph")
    temp = data.get("temperature")
    hum = data.get("humidity")
    rain = data.get("rainfall")
    soil_type = data.get("soil_type", "Loamy") # fallback to Loamy if not provided
    
    # We map parameters that are strings just in case they are parsed as strings
    try: n = float(n) if n is not None else None
    except: pass
    try: p = float(p) if p is not None else None
    except: pass
    try: k = float(k) if k is not None else None
    except: pass
    try: ph = float(ph) if ph is not None else None
    except: pass
    try: temp = float(temp) if temp is not None else None
    except: pass
    try: hum = float(hum) if hum is not None else None
    except: pass
    try: rain = float(rain) if rain is not None else None
    except: pass

    # Summary generator
    soil_disp = f" ({soil_type})" if soil_type else ""
    summary_sentence = f"Based on nitrogen ({n if n is not None else 'N/A'} kg/ha), phosphorus ({p if p is not None else 'N/A'} kg/ha), potassium ({k if k is not None else 'N/A'} kg/ha), rainfall ({rain if rain is not None else 'N/A'} mm), temperature ({temp if temp is not None else 'N/A'}C), and soil type{soil_disp}, the environmental and biochemical conditions strongly support {recommended_crop.capitalize()} cultivation."

    # Strategy-specific context
    strategy = data.get("farming_strategy", "Seasonal Farming")
    strategy_comment = ""
    if strategy == "Short-Term Profit":
        strategy_comment = "\n\n**Strategy Focus: Short-Term Profit**\nThis crop was prioritized for its high market demand and short growth cycle, maximizing liquidity and turnaround time."
    elif strategy == "Long-Term Soil Health":
        strategy_comment = "\n\n**Strategy Focus: Long-Term Soil Health**\nSelections favored crops with nitrogen-fixing capabilities or low nutrient depletion profiles to restore soil vitality for future seasons."
    elif strategy == "Water Saving Farming":
        strategy_comment = "\n\n**Strategy Focus: Water Saving**\nPrioritized drought-tolerant species that minimize irrigation dependency and handle moisture stress effectively."
    elif strategy == "Organic Farming":
        strategy_comment = "\n\n**Strategy Focus: Organic Farming**\nChosen for its natural resistance to local pests and compatibility with biofertilizer regimens, reducing chemical reliance."

    report = (
        f"**Scientific Suitability Analysis**\n\n"
        f"**1. Nitrogen Analysis**\n"
        f"{analyze_nitrogen(n, recommended_crop)}\n\n"
        f"**2. Phosphorus Analysis**\n"
        f"{analyze_phosphorus(p, recommended_crop)}\n\n"
        f"**3. Potassium Analysis**\n"
        f"{analyze_potassium(k, recommended_crop)}\n\n"
        f"**4. Soil pH Analysis**\n"
        f"{analyze_ph(ph, recommended_crop)}\n\n"
        f"**5. Rainfall Analysis**\n"
        f"{analyze_rainfall(rain, recommended_crop)}\n\n"
        f"**6. Temperature Analysis**\n"
        f"{analyze_temperature(temp, recommended_crop)}\n\n"
        f"**7. Humidity Analysis**\n"
        f"{analyze_humidity(hum, recommended_crop)}\n\n"
        f"**8. Soil Type Analysis**\n"
        f"{analyze_soil_type(soil_type, recommended_crop)}\n\n"
        f"**9. Final Scientific Conclusion**\n"
        f"{summary_sentence}"
        f"{strategy_comment}"
    )

    return report
