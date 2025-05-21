import qrcode
import qrcode.image.pil
from PIL import Image, ImageDraw, ImageFont
import uuid

# Générer un UUID aléatoire
uuid_str = str(uuid.uuid4())

# Extraire les 8 derniers chiffres de l'UUID
serie_chiffres = uuid_str[-8:]

# Créer le code QR
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=2,
)
qr.add_data(uuid_str)
qr.make(fit=True)

qr_img = qr.make_image(fill_color="black", back_color="white")

# Ajouter la série de chiffres en bas de l'image
draw = ImageDraw.Draw(qr_img)
font = ImageFont.truetype("arial.ttf", 16)

# Coordonnées pour placer le texte en bas
text_x = 130
text_y = qr_img.size[1] - 17

# Ajout du texte à l'image
draw.text((text_x, text_y), serie_chiffres, fill="black", font=font)

# Enregistrer l'image
qr_img.save("qr_code_with_serie.png")


