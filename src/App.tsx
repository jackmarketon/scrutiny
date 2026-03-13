import { useEffect, useRef, useState } from "react";
import { invoke } from "@tauri-apps/api/core";
import { EditorView, basicSetup } from "codemirror";
import { markdown } from "@codemirror/lang-markdown";
import { MergeView } from "@codemirror/merge";

interface Comment {
  line: number;
  text: string;
}

interface PlanData {
  id: string;
  original: string;
  edited: string | null;
}

function App() {
  const editorRef = useRef<HTMLDivElement>(null);
  const [planData, setPlanData] = useState<PlanData | null>(null);
  const [comments, setComments] = useState<Comment[]>([]);
  const [currentEdit, setCurrentEdit] = useState("");
  const [showCommentDialog, setShowCommentDialog] = useState(false);
  const [selectedLine, setSelectedLine] = useState(0);
  const [commentText, setCommentText] = useState("");

  // Load plan on mount
  useEffect(() => {
    const planPath = new URLSearchParams(window.location.search).get("plan");
    if (planPath) {
      invoke<PlanData>("load_plan", { planPath }).then((data) => {
        setPlanData(data);
        setCurrentEdit(data.original);
      });
    }
  }, []);

  // Initialize CodeMirror merge view
  useEffect(() => {
    if (!editorRef.current || !planData) return;

    const view = new MergeView({
      a: {
        doc: planData.original,
        extensions: [basicSetup, markdown()],
      },
      b: {
        doc: currentEdit,
        extensions: [
          basicSetup,
          markdown(),
          EditorView.updateListener.of((update) => {
            if (update.docChanged) {
              setCurrentEdit(update.state.doc.toString());
            }
          }),
          EditorView.domEventHandlers({
            click: (event, view) => {
              const pos = view.posAtCoords({ x: event.clientX, y: event.clientY });
              if (pos !== null) {
                const line = view.state.doc.lineAt(pos).number;
                setSelectedLine(line);
              }
            },
          }),
        ],
      },
      parent: editorRef.current,
    });

    return () => {
      view.destroy();
    };
  }, [planData]);

  const handleAddComment = () => {
    setShowCommentDialog(true);
  };

  const saveComment = () => {
    if (commentText.trim()) {
      setComments([...comments, { line: selectedLine, text: commentText }]);
      setCommentText("");
      setShowCommentDialog(false);
    }
  };

  const handleApprove = async () => {
    if (!planData) return;

    try {
      await invoke("save_feedback", {
        planPath: `/tmp/claude-plans/${planData.id}.md`,
        comments,
        editedPlan: currentEdit,
      });

      // Close window
      window.close();
    } catch (error) {
      console.error("Failed to save feedback:", error);
      alert(`Error: ${error}`);
    }
  };

  const handleReject = () => {
    window.close();
  };

  return (
    <div className="container">
      <header>
        <h1>Claude Plan Review</h1>
        <div className="header-actions">
          <button onClick={handleAddComment} className="btn-secondary">
            💬 Add Comment (Line {selectedLine})
          </button>
        </div>
      </header>

      <div className="editor-container">
        <div ref={editorRef} className="merge-view" />
      </div>

      {comments.length > 0 && (
        <div className="comments-panel">
          <h3>Comments ({comments.length})</h3>
          {comments.map((comment, idx) => (
            <div key={idx} className="comment">
              <span className="comment-line">Line {comment.line}:</span>
              <span className="comment-text">{comment.text}</span>
            </div>
          ))}
        </div>
      )}

      {showCommentDialog && (
        <div className="modal-overlay" onClick={() => setShowCommentDialog(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Add Comment at Line {selectedLine}</h2>
            <textarea
              value={commentText}
              onChange={(e) => setCommentText(e.target.value)}
              placeholder="Your feedback..."
              rows={4}
              autoFocus
            />
            <div className="modal-actions">
              <button onClick={saveComment} className="btn-primary">
                Save Comment
              </button>
              <button onClick={() => setShowCommentDialog(false)} className="btn-secondary">
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}

      <footer>
        <button onClick={handleApprove} className="btn-primary">
          ✓ Approve & Send Feedback
        </button>
        <button onClick={handleReject} className="btn-secondary">
          ✗ Cancel
        </button>
      </footer>
    </div>
  );
}

export default App;
