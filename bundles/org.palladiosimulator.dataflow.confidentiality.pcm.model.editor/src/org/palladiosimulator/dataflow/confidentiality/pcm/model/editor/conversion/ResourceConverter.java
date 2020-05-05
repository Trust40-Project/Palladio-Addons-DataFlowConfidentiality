package org.palladiosimulator.dataflow.confidentiality.pcm.model.editor.conversion;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;

@FunctionalInterface
public interface ResourceConverter {
 
    void convert(IFile file) throws CoreException;
    
}
