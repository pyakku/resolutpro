// Paths to brand assets in /public/resolut_branding. Filenames contain spaces,
// so they are URL-encoded for use as image src values.
const DIR = "/resolut_branding";

export const LOGO = {
  proBlack: `${DIR}/Resolut.%20Pro%20Logo%20Black.png`,
  proWhite: `${DIR}/Resolut.%20Pro%20Logo%20White.png`,
  regBlack: `${DIR}/Resolut.%20Reg%20Logo%20Black.png`,
  fullBlack: `${DIR}/Resolut%20Logo%20Black.png`,
  fullWhite: `${DIR}/Resolut%20Logo%20White.png`,
  icon: `${DIR}/Icon.png`,
} as const;
