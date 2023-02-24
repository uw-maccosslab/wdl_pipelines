from setuptools import setup, find_packages

setup(name='test_scripts',
      version=0.1,
      author='Aaron Maurais',
      # url='https://github.com/ajmaurais/PDC_client',
      packages=find_packages(),
      package_dir={'test_scripts': 'src'},
      python_requires='>=3.8',
      install_requires=['pandas>=1.5.3'],
      entry_points={'console_scripts': ['compare_cromwell_output=src:compare_cromwell_output',
                                        'generate_cromwell_inputs=src:generate_cromwell_inputs']}
)
