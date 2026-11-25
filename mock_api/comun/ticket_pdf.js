function construirTicketPdf(lineas) {
  const escapar = (t) => t.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');

  let texto = 'BT /F1 12 Tf 72 780 Td 16 TL\n';
  for (const linea of lineas) texto += `(${escapar(linea)}) Tj T*\n`;
  texto += 'ET';

  const objetos = [
    null,
    '<< /Type /Catalog /Pages 2 0 R >>',
    '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] ' +
      '/Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>',
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    `<< /Length ${Buffer.byteLength(texto, 'latin1')} >>\nstream\n${texto}\nendstream`,
  ];

  let pdf = '%PDF-1.4\n';
  const posiciones = [];
  for (let i = 1; i < objetos.length; i++) {
    posiciones[i] = Buffer.byteLength(pdf, 'latin1');
    pdf += `${i} 0 obj\n${objetos[i]}\nendobj\n`;
  }

  const inicioXref = Buffer.byteLength(pdf, 'latin1');
  const total = objetos.length;
  pdf += `xref\n0 ${total}\n0000000000 65535 f \n`;
  for (let i = 1; i < total; i++) {
    pdf += `${String(posiciones[i]).padStart(10, '0')} 00000 n \n`;
  }
  pdf += `trailer\n<< /Size ${total} /Root 1 0 R >>\nstartxref\n${inicioXref}\n%%EOF\n`;

  return Buffer.from(pdf, 'latin1');
}

module.exports = construirTicketPdf;
