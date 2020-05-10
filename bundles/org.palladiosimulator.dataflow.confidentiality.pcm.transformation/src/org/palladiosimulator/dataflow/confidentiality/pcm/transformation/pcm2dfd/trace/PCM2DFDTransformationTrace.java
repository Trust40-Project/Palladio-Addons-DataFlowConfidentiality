package org.palladiosimulator.dataflow.confidentiality.pcm.transformation.pcm2dfd.trace;

import java.util.Collection;
import java.util.function.Predicate;

import org.eclipse.emf.ecore.EObject;

import de.uka.ipd.sdq.identifier.Identifier;

public interface PCM2DFDTransformationTrace {

    Collection<DFDTraceElement> getDFDEntries(EObject pcmElement);
    Collection<DFDTraceElement> getDFDEntries(EObject pcmElement, Collection<Identifier> pcmElementContext);
    Collection<DFDTraceElement> getDFDEntries(Predicate<PCMTraceElement> pcmElement);
    Collection<PCMSingleTraceElement> getPCMEntries(Identifier dfdElement);
    
}
