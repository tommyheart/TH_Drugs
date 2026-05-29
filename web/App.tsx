import { useState, useCallback, useEffect } from 'react';
import { isDebug, useNuiEvent, fetchNui } from './hooks/useNui';

export default function App() {
  const [visible, setVisible] = useState(isDebug);

  useNuiEvent('open', () => setVisible(true));
  useNuiEvent('close', () => setVisible(false));

  const handleClose = useCallback(() => {
    setVisible(false);
    fetchNui('close', {}, { success: true });
  }, []);

  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') handleClose();
    };
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [handleClose]);

  if (!visible) return null;

  return (
    <div className="w-screen h-screen flex items-center justify-center">
      <main className="w-[600px] max-w-[90vw] bg-zinc-900/90 border border-zinc-700 rounded-lg shadow-2xl p-6">
        <div className="flex items-center justify-between mb-4">
          <h1 className="text-white text-xl font-semibold">My Panel</h1>
          <button
            onClick={handleClose}
            className="text-zinc-400 hover:text-white transition-colors text-lg leading-none"
          >
            ✕
          </button>
        </div>
        <p className="text-zinc-400 text-sm">Your NUI is ready. Start building!</p>
      </main>
    </div>
  );
}
