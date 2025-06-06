import React, { useEffect, useRef } from 'react';

const FormulaBox = ({ children, dir = 'rtl', isBlock = false }) => {
  const className = isBlock ? 'formula-box-block' : 'formula-box';
  const spanRef = useRef(null);

  const typesetMath = () => {
    if (window.MathJax && window.MathJax.typesetPromise && spanRef.current) {
      window.MathJax.typesetPromise([spanRef.current])
        .then(() => {
          // console.log('MathJax typeset successfully for:', children);
        })
        .catch((err) => {
          console.error('MathJax typesetting error in FormulaBox for:', children, err);
        });
    } else {
      // console.warn('MathJax not ready or spanRef.current is null when trying to typeset:', children);
    }
  };

  useEffect(() => {
    const handleMathJaxReady = () => {
      // console.log('MathJaxReady event received in FormulaBox for:', children);
      typesetMath();
    };

    if (window.mathJaxInitialized) {
      // console.log('MathJax already initialized, typesetting for:', children);
      typesetMath();
    } else {
      // console.log('MathJax not yet initialized, adding event listener for:', children);
      document.addEventListener('MathJaxReady', handleMathJaxReady);
    }

    return () => {
      // console.log('Cleaning up MathJaxReady event listener for:', children);
      document.removeEventListener('MathJaxReady', handleMathJaxReady);
    };
  }, [children]); // Re-run when children (the formula string) change

  return (
    <span ref={spanRef} className={className} dir={dir}>
      {children}
    </span>
  );
};

export default FormulaBox;
