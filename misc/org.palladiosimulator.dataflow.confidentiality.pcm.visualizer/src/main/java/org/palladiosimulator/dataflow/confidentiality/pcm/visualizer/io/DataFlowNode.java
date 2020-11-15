package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

public class DataFlowNode extends ParentHaving<DataFlowGraph> {

	private int id;
	private DataFlowNodeElement element;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public DataFlowNodeElement getElement() {
		return element;
	}

	public void setElement(DataFlowNodeElement element) {
		this.element = element;
	}

	@Override
	protected void setParentForChildren() {
		element.setParent(this);
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = super.hashCode();
		result = prime * result + ((element == null) ? 0 : element.hashCode());
		result = prime * result + id;
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (!super.equals(obj))
			return false;
		if (getClass() != obj.getClass())
			return false;
		DataFlowNode other = (DataFlowNode) obj;
		if (element == null) {
			if (other.element != null)
				return false;
		} else if (!element.equals(other.element))
			return false;
		if (id != other.id)
			return false;
		return true;
	}

}
