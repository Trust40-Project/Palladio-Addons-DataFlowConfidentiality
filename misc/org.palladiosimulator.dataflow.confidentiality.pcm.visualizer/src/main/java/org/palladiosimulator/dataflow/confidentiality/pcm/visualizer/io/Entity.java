package org.palladiosimulator.dataflow.confidentiality.pcm.visualizer.io;

public class Entity extends Identifiable implements DataFlowResultElement {

	private String name;

	public Entity() {
		
	}
	
	public Entity(String id, String name) {
		this.name = name;
		setId(id);
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = super.hashCode();
		result = prime * result + ((name == null) ? 0 : name.hashCode());
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
		Entity other = (Entity) obj;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return "Entity [getName()=" + getName() + ", getId()=" + getId() + "]";
	}

}
