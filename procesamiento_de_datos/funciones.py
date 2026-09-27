import re
import spacy

def limpiar_y_separar_simbolos(texto: str) -> str:
    """
    Inserta un espacio entre palabras y caracteres no alfanuméricos/emojis
    para evitar que queden pegados como un solo token erróneo.
    """
    # Separa letras de cualquier cosa que no sea letra, número o espacio
    texto = re.sub(r'([^\w\s])', r' \1 ', texto)
    
    # Normaliza espacios múltiples a uno solo
    texto = re.sub(r'\s+', ' ', texto).strip()
    return texto

def extraer_lemas(textos_limpios,vector_lemas,nlp):
    """
    Extrae lemas de una lista de textos limpios utilizando spaCy."""
    for doc in nlp.pipe(textos_limpios, batch_size=50):
        for token in doc:
            # Filtramos signos de puntuación, espacios y palabras vacías (stopwords)
            if not token.is_punct and not token.is_space and not token.is_stop:
                vector_lemas.append(token.lemma_.lower())

def guardar_lemas_en_archivo(vector_lemas, nombre_archivo_txt):
    with open(nombre_archivo_txt, "w", encoding="utf-8") as f:
        for lema in vector_lemas:
            f.write(f"{lema}\n")
    print(f"Archivo guardado exitosamente: {nombre_archivo_txt}")
