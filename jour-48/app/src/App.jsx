import { useEffect, useMemo, useState } from 'react'
import { buildInfo } from './buildInfo'
import './App.css'

const STORAGE_KEY = 'mes-taches'

const FILTERS = [
  { id: 'all', label: 'Toutes' },
  { id: 'active', label: 'À faire' },
  { id: 'done', label: 'Terminées' },
]

const EMPTY_MESSAGES = {
  all: 'Aucune tâche pour l’instant. Ajoute ta première tâche ci-dessus.',
  active: 'Tout est fait. Bravo !',
  done: 'Aucune tâche terminée pour l’instant.',
}

function loadTasks() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : []
  } catch {
    return []
  }
}

function newId() {
  return Date.now().toString(36) + Math.random().toString(36).slice(2, 8)
}

export default function App() {
  const [tasks, setTasks] = useState(loadTasks)
  const [text, setText] = useState('')
  const [error, setError] = useState('')
  const [filter, setFilter] = useState('all')

  // Sauvegarde automatique dans le navigateur
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(tasks))
    } catch {
      /* stockage indisponible : on ignore */
    }
  }, [tasks])

  const remaining = tasks.filter((t) => !t.done).length
  const hasDone = tasks.some((t) => t.done)

  const visibleTasks = useMemo(() => {
    if (filter === 'active') return tasks.filter((t) => !t.done)
    if (filter === 'done') return tasks.filter((t) => t.done)
    return tasks
  }, [tasks, filter])

  function addTask(event) {
    event.preventDefault()
    const title = text.trim()
    if (!title) {
      setError('Écris une tâche avant de l’ajouter.')
      return
    }
    setTasks((prev) => [{ id: newId(), title, done: false }, ...prev])
    setText('')
    setError('')
  }

  function toggleTask(id) {
    setTasks((prev) => prev.map((t) => (t.id === id ? { ...t, done: !t.done } : t)))
  }

  function removeTask(id) {
    setTasks((prev) => prev.filter((t) => t.id !== id))
  }

  function clearDone() {
    setTasks((prev) => prev.filter((t) => !t.done))
  }

  return (
    <div className="page">
      <main className="sheet">
        <header>
          <h1>My DevOps Tasks</h1>
          <p className="count" aria-live="polite">
            {tasks.length === 0
              ? 'Commence par ajouter une tâche.'
              : remaining === 0
                ? 'Rien à faire, profite !'
                : `${remaining} tâche${remaining > 1 ? 's' : ''} à faire`}
          </p>
        </header>

        <form className="add" onSubmit={addTask} noValidate>
          <label htmlFor="new-task" className="sr-only">
            Nouvelle tâche
          </label>
          <input
            id="new-task"
            type="text"
            value={text}
            placeholder="Ex. Configurer le webhook GitHub"
            autoComplete="off"
            aria-invalid={error ? 'true' : 'false'}
            aria-describedby={error ? 'task-error' : undefined}
            onChange={(e) => {
              setText(e.target.value)
              if (error) setError('')
            }}
          />
          <button type="submit">Ajouter</button>
        </form>
        {error && (
          <p id="task-error" className="error" role="alert">
            {error}
          </p>
        )}

        {tasks.length > 0 && (
          <div className="toolbar">
            <div className="filters" role="group" aria-label="Filtrer les tâches">
              {FILTERS.map((f) => (
                <button
                  key={f.id}
                  type="button"
                  aria-pressed={filter === f.id}
                  onClick={() => setFilter(f.id)}
                >
                  {f.label}
                </button>
              ))}
            </div>
            {hasDone && (
              <button type="button" className="link" onClick={clearDone}>
                Effacer les terminées
              </button>
            )}
          </div>
        )}

        {visibleTasks.length === 0 ? (
          <p className="empty">{EMPTY_MESSAGES[filter]}</p>
        ) : (
          <ul className="list">
            {visibleTasks.map((task) => (
              <li key={task.id} className={task.done ? 'task done' : 'task'}>
                <label className="check">
                  <input
                    type="checkbox"
                    checked={task.done}
                    onChange={() => toggleTask(task.id)}
                  />
                  <span className="box" aria-hidden="true" />
                  <span className="title">{task.title}</span>
                </label>
                <button
                  type="button"
                  className="remove"
                  aria-label={`Supprimer « ${task.title} »`}
                  onClick={() => removeTask(task.id)}
                >
                  ×
                </button>
              </li>
            ))}
          </ul>
        )}
      </main>

      <footer className="stamp" aria-label="Informations de déploiement">
        <span className={buildInfo.number ? 'status live' : 'status'}>
          {buildInfo.number ? 'Déployé par Jenkins' : 'Version locale'}
        </span>
        <dl>
          <div>
            <dt>Build</dt>
            <dd>{buildInfo.number ? `#${buildInfo.number}` : '–'}</dd>
          </div>
          <div>
            <dt>Commit</dt>
            <dd>{buildInfo.commit}</dd>
          </div>
          <div>
            <dt>Date</dt>
            <dd>{buildInfo.date}</dd>
          </div>
        </dl>
      </footer>
    </div>
  )
}