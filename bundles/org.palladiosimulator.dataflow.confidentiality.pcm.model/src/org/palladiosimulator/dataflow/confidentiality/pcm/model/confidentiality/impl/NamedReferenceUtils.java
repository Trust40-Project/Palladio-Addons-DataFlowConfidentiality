package org.palladiosimulator.dataflow.confidentiality.pcm.model.confidentiality.impl;

import de.uka.ipd.sdq.stoex.AbstractNamedReference;
import de.uka.ipd.sdq.stoex.NamespaceReference;

public final class NamedReferenceUtils {

    private NamedReferenceUtils() {
        // intentionally left blank
    }

    public static String toString(AbstractNamedReference reference) {
        var result = "";
        var currentSegment = reference;
        while (currentSegment != null) {
            result += currentSegment.getReferenceName();
            if (currentSegment instanceof NamespaceReference) {
                result += ".";
                currentSegment = ((NamespaceReference) currentSegment).getInnerReference_NamespaceReference();
                continue;
            }
            currentSegment = null;
        }
        return result;
    }

}
