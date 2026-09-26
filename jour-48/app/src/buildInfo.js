// Ces valeurs sont injectées par Jenkins au moment du build (voir Jenkinsfile).
// En local, on affiche des valeurs par défaut.
export const buildInfo = {
  number: import.meta.env.VITE_BUILD_NUMBER || null,
  commit: import.meta.env.VITE_GIT_COMMIT || 'local',
  date: import.meta.env.VITE_BUILD_DATE || 'maintenant',
}